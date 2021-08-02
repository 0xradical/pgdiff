module PgDiff
  class Database
    attr_reader :catalog, :world, :queries

    def initialize(label, dbparams = {})
      @label = label
      @retries = 0

      loop do
        if @retries > 10
          print "Giving up!"
          puts "There's something wrong with your database"
          exit(1)
        end
        begin
          @pg = PG.connect(dbparams)
          if @retries > 0
            print "Done"
          end
          break
        rescue PG::ConnectionBad
          print "Waiting for database '#{@label}' to be up... "
          sleep(1)
          @retries += 1
        end
      end

      setup
    end

    def connection; @pg; end

    def build_object(objdata, objclass)
      case objclass
      when Models::Table
        objclass.new(objdata).tap do |table|
          table.add_columns(@queries.table_columns(table.name))
          table.add_constraints(@queries.table_constraints(table.name))
          table.add_indexes(@queries.table_indexes(table.name))
          table.add_options(@queries.table_options(table.name))
          table.add_privileges(@queries.table_privileges(table.name))
        end
      when Models::View
        objclass.new(objdata).tap do |view|
          view.add_privileges(
            view.materialized? ?  @queries.materialized_view_privileges(view.name) :
                                  @queries.view_privileges(view.name)
          )
        end
      when Models::Function
        objclass.new(objdata).tap do |function|
          function.add_privileges(@queries.function_privileges(function.name, function.argtypes))
        end
      when Models::Sequence
        objclass.new(objdata).tap do |sequence|
          sequence.add_privileges(@queries.sequence_privileges(sequence.name))
        end
      when Models::Domain
        objclass.new(objdata).tap do |domain|
          domain.add_constraints(@queries.domain_constraints(domain.name))
        end
      else
        objclass.new(objdata)
      end
    end

    def setup
      @world   ||= (PgDiff::World[@label] = PgDiff::World.new)
      @catalog ||= PgDiff::Catalog.new(@pg, @label)
      @queries ||= PgDiff::Queries.new(@pg)

      @queries.dependency_pairs.each do |dep|
        objdata  = @world.objects[dep["objid"]]

        object = case objdata
        when Hash
          objclass = @world.classes[dep["objid"]]
          @world.objects[dep["objid"]] = build_object(objdata, objclass)
        when NilClass
          @world.classes[dep["objid"]] = Models::Unmapped
          @world.objects[dep["objid"]] = PgDiff::Models::Unmapped.new(dep["objid"], dep["object_identity"], dep["object_type"], @label)
        else
          objdata
        end

        chain    = (JSON.parse(dep["dependency_chain"]) rescue [])
        # chain[-1] == object
        refobjid = chain[-2]

        if refobjid
          referenced = @world.objects[refobjid]

          @world.add_dependency(
            PgDiff::Dependency.new(
              object,
              referenced,
              dep["dependency_type"]
            )
          )
        end
      end

      # objects that do not appear on dependency pairs
      @world.objects.select do |id,o|
        o.is_a?(Hash)
      end.each do |id,o|
        objdata  = o
        objclass = @world.classes[id]

        if objdata
          @world.objects[id] = build_object(objdata, objclass)
        end
      end
    end
  end
end