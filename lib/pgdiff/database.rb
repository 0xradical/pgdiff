module PgDiff
  class Database
    attr_reader :label, :catalog, :world, :queries

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
            puts "Done"
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
      case objclass.name
      when "PgDiff::Models::Table"
        objclass.new(objdata).tap do |table|
          table.add_options(@queries.table_options(table.name))
          # only constraints and indexes have objid
          # so they should be added to world
          tconstraints = @queries.table_constraints(table.name)
          tindexes = @queries.table_indexes(table.name)

          tconstraints.each do |tc|
            @world.objects[tc["objid"]] = [tc,table]
            @world.classes[tc["objid"]] = PgDiff::Models::TableConstraint
          end

          tindexes.each do |ti|
            @world.objects[ti["objid"]] = [ti,table]
            @world.classes[ti["objid"]] = PgDiff::Models::TableIndex
          end

          table.add_constraints(tconstraints)
          table.add_indexes(tindexes)
        end
      when "PgDiff::Models::TableConstraint", "PgDiff::Models::TableIndex"
        objclass.new(objdata[0], objdata[1])
      when "PgDiff::Models::View"
        objclass.new(objdata)
      when "PgDiff::Models::Function"
        objclass.new(objdata)
      when "PgDiff::Models::Sequence"
        objclass.new(objdata)
      when "PgDiff::Models::Domain"
        objclass.new(objdata)
      when "PgDiff::Models::DomainConstraint"
        domain = @world.find_by_gid("TYPE #{objdata['domain_name']}")
        if domain
          objclass.new(objdata, domain).tap do |constraint|
            domain.add_constraint(constraint)
          end
        else
          @world.objects[objdata["objid"]] = PgDiff::Models::Unmapped.new(objdata["objid"], objdata["identity"], "DOMAIN CONSTRAINT", @label)
          @world.gids[@world.objects[objdata["objid"]].gid] = objdata["objid"]
          @world.objects[objdata["objid"]]
        end
      else
        objclass.new(objdata)
      end
    end

    def setup
      @world   ||= (PgDiff::World[@label] = PgDiff::World.new)
      puts "Cataloguing objects from database #{@label}..."
      @catalog ||= PgDiff::Catalog.new(@pg, @label)
      @queries ||= PgDiff::Queries.new(@pg, @label)
      @subids    = []

      puts "Pulling in dependency pairs from #{@label}..."
      @queries.dependency_pairs.each do |dep|
        objdata  = @world.objects[dep["objid"]]

        object = case objdata
        when Hash, Array
          objclass = @world.classes[dep["objid"]]
          @world.objects[dep["objid"]] = build_object(objdata, objclass)
          @world.gids[@world.objects[dep["objid"]].gid] = dep["objid"]
          @world.objects[dep["objid"]]
        when NilClass
          @world.classes[dep["objid"]] = Models::Unmapped
          @world.objects[dep["objid"]] = PgDiff::Models::Unmapped.new(dep["objid"], dep["object_identity"], dep["object_type"], @label)
          @world.gids[@world.objects[dep["objid"]].gid] = dep["objid"]
          @world.objects[dep["objid"]]
        else
          objdata
        end

        chain    = (JSON.parse(dep["dependency_chain"]) rescue [])
        # chain[-1] == object
        refobjid = chain[-2]

        if object && refobjid
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
      # for some reason...
      puts "Fixing objects that need manual dependency management on #{@label}..."
      @world.objects.select do |id,o|
        o.is_a?(Hash)
      end.each do |id,o|
        objdata  = o
        objclass = @world.classes[id]

        if objdata
            @world.objects[id] = build_object(objdata, objclass)
          if @world.gids[@world.objects[id]]
            @world.gids[@world.objects[id].gid] = id
          end
        end
      end

      # process columns because some types
      # don't appear on pg_depend ?
      # also, their default types might be string based
      puts "Adding table columns dependencies on #{@label} ..."
      @world.tables.values.each do |table|
        table.columns.each do |column|
          type = @world.types[column.type] || @world.enums[column.type] || @world.domains[column.type]
          @world.add_dependency(
            PgDiff::Dependency.new(
              table,
              type,
              "normal"
            )
          )

          if column.adsrc
            # is adsrc a function ?
            # ideally parse adbin for more complex cases...
            args = column.adsrc[/\((.*)\)/,1]
            if args && column.adsrc.sub("#{args})",'') !~ /^\(/
              function = @world.functions.values.select{|f| f.gid =~  /#{Regexp.escape(column.adsrc.sub("#{args})",''))}/}.first
              if function
                column.default_value_fn = "#{function.name}(#{args})"
                @world.add_dependency(
                  PgDiff::Dependency.new(
                    table,
                    function,
                    "normal"
                  )
                )
              end
            end
          end
        end
      end

      # Adding table constraints dependencies
      puts "Adding constraints dependencies on #{@label} ..."
      @world.constraints.values.each do |constraint|
        table  = @world.objects[constraint.conrelid]
        ftable = @world.objects[constraint.confrelid]

        if table && ftable
          @world.add_dependency(
            PgDiff::Dependency.new(
              table,
              ftable,
              "normal"
            )
          )
        end

        # conbin (CHECK) might have function calls...
        # :funcid 1381 :funcresulttype 23
        # ideally, we have to grab every single thing that has an
        # id and create a dependency...
        if constraint.conbin
          constraint.conbin.scan(/:funcid (\d+)/).each do |scanr|
            function = @world.objects[scanr[0]]

            if function
              @world.add_dependency(
                PgDiff::Dependency.new(
                  table,
                  function,
                  "normal"
                )
              )
            end
          end
        end
      end

      # views have dependencies mapped outside pg_depend
      puts "Adding views dependencies on #{@label} ..."
      @world.rules.values.each do |rule|
        rule.ops.each do |op|
          # original view
          view = @world.find_by_gid("VIEW #{op['viewname']}") || @world.find_by_gid("MATERIALIZED VIEW #{op['viewname']}")

          # rule depend on each column
          column = @world.find_by_gid("TABLE COLUMN #{op['columnname']} ON #{op['schemaname']}.#{op['tablename']}")

          if column
            @world.add_dependency(
              PgDiff::Dependency.new(
                view,
                column,
                "internal"
              )
            )
          end

          # if rule depends on another view lol
          oview = @world.find_by_gid("VIEW #{op['schemaname']}.#{op['tablename']}") || @world.find_by_gid("MATERIALIZED VIEW #{op['schemaname']}.#{op['tablename']}")
          if oview
            @world.add_dependency(
              PgDiff::Dependency.new(
                view,
                oview,
                "internal"
              )
            )
          end
          # if rule depends on another function
          viewfn = @world.objects[op['fobjid']]
          if viewfn
            @world.add_dependency(
              PgDiff::Dependency.new(
                view,
                viewfn,
                "internal"
              )
            )
          end
        end
      end

      # these attributes are not seen on pg_depend either ...
      puts "Adding composite types dependencies on #{@label} ..."
      @world.types.values.each do |type|
        type.columns.each do |attribute|
          attribute_type = @world.objects[attribute['objid']]
          if attribute_type
            @world.add_dependency(
              PgDiff::Dependency.new(
                type,
                attribute_type,
                "normal"
              )
            )
          end
        end
      end

      puts "Adding sequence dependencies for tables on #{@label} ..."
      @world.sequences.values.each do |sequence|
        table = @world.find_by_gid("TABLE #{sequence.ownedby_table}")

        if table
          @world.add_dependency(
            PgDiff::Dependency.new(
              table,
              sequence,
              "normal"
            )
          )
        end
      end

      puts "Adding plpgsql function dependencies on #{@label} ..."
      @world.functions.values.each do |function|
        begin
          possible_types = function.definition[/DECLARE\s+([\s\S]+)\s+BEGIN/,1].split(";").map(&:strip).map{|s| s.split(/\s+/)}.flatten

          possible_types.each do |ptype|
            type = @world.find_by_gid("TYPE #{ptype}")
            if type
              @world.add_dependency(
                PgDiff::Dependency.new(
                  function,
                  type,
                  "internal"
                )
              )
            end
          end
        rescue
          next
        end
      end

      # remove objects that have no mapping...
      @world.objects.select{|k,v| v.nil? }.each{|k,v| @world.objects.delete(k) }
    end
  end
end