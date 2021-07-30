module PgDiff
  class Database
    attr_reader :catalog, :deps

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

    def setup
      @deps    ||= PgDiff::Deps.new(@pg)
      @catalog ||= PgDiff::Catalog.new(@pg)

      report_to_world
      feedback_into_catalog
    end

    def report_to_world
      @deps.flat_tree.each do |object|
        id = "#{object['object_type']}|#{object['object_identity']}"

        PgDiff::World::IDS[object["objid"]] = id

        PgDiff::World::OBJECTS[id] = {
          "id" => object["objid"],
          "chain" => object['dependency_chain'][/\{(.*)\}/,1].split(",")[0..-2],
          "type" => object["dependency_type"]
        }
      end
    end

    def feedback_into_catalog
      # first pass, assign everyone an id from world
      @catalog.each_object(deep: true) do |object|
        id = "#{object.world_type}|#{object.world_id}"
        if PgDiff::World::OBJECTS[id]
          PgDiff::World::OBJECTS[id]["model"] = object
          object.id = PgDiff::World::OBJECTS[id]["id"]
        end
      end
      # second pass, assign dependencies based on pgdiff::world
      @catalog.each_object(deep: true) do |object|
        id = "#{object.world_type}|#{object.world_id}"

        if PgDiff::World::OBJECTS[id]
          if PgDiff::World::OBJECTS[id]["chain"].length > 0
            object.dependency_type = PgDiff::World::OBJECTS[id]["type"]
            object.depend_on = PgDiff::World::OBJECTS[id]["chain"].map do |dep_id|
              PgDiff::World::OBJECTS[PgDiff::World::IDS[dep_id]]["model"]
            end
          else
            object.dependency_type = "none"
            object.depend_on = []
          end
        end
      end

      PgDiff::World::OBJECTS.clear
      PgDiff::World::IDS.clear
    end
  end
end