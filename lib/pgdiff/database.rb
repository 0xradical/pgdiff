module PgDiff
  class Database
    attr_reader :catalog, :world

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

    def setup
      @world   ||= (PgDiff::World[@label] = PgDiff::World.new)
      @catalog ||= PgDiff::Catalog.new(@pg, @label)

      PgDiff::Queries.new(@pg).dependency_pairs.each do |dep|
        object = @world.objects[dep["objid"]]

        if !object
          object = PgDiff::Models::Unmapped.new(dep["objid"], dep["object_identity"], dep["object_type"])
        end

        referenced = @world.objects[dep["refobjid"]]

        if !referenced
          referenced = PgDiff::Models::Unmapped.new(dep["refobjid"], dep["refobj_identity"], dep["refobj_type"])
        end

        @world.add_dependency(
          PgDiff::Dependency.new(
            object,
            referenced,
            dep["dependency_type"]
          )
        )
      end
    end
  end
end