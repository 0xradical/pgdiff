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
        chain = Set.new(object['dependency_chain'][/\{(.*)\}/,1].split(",")[0..-2])

        PgDiff::World::IDS[object["objid"]] = id

        if (current = PgDiff::World::OBJECTS[id])
          PgDiff::World::OBJECTS[id]["chain"] = chain | PgDiff::World::OBJECTS[id]["chain"]
        else
          PgDiff::World::OBJECTS[id] = {
            "id" => object["objid"],
            "chain" => chain,
            "type" => object["dependency_type"]
          }
        end
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

            depend_on = PgDiff::World::OBJECTS[id]["chain"].map do |dep_id|
              if PgDiff::World::OBJECTS[PgDiff::World::IDS[dep_id]]["model"]
                PgDiff::World::OBJECTS[PgDiff::World::IDS[dep_id]]["model"]
              else
                name, world_type = PgDiff::World::IDS[dep_id].split("|")
                PgDiff::World::OBJECTS[PgDiff::World::IDS[dep_id]]["model"] = PgDiff::Models::Unmapped.new(name, world_type)
              end
            end.to_a

            (0.upto(depend_on.length-2)).each do |cutoff_index|
              parent = depend_on[cutoff_index]

              depend_on[(cutoff_index+1)..-1].each { |dependency| parent.add_dependency(dependency) }
            end

            object.depend_on = Set.new(depend_on)
          else
            object.dependency_type = "none"
            object.depend_on = Set.new([])
          end
        end
      end

      PgDiff::World::OBJECTS.clear
      PgDiff::World::IDS.clear
    end
  end
end