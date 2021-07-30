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
        PgDiff::World["#{object['object_type']}:#{object['object_identity']}"] = {
          "id" => object["objid"],
          "chain" => object['dependency_chain'][/\{(.*)\}/,1].split(",")[0..-2],
          "type" => object["dependency_type"]
        }
      end
    end

    def feedback_into_catalog
      binding.pry
      # first pass, assign everyone an id from world
      @catalog.each do |object|
        PgDiff::World[object.world_id]["model"] = object
        object.id = PgDiff::World[object.world_id]
      end
      # second pass, assign dependencies based on pgdiff::world
      @catalog.each do |object|
        object.dependencies = PgDiff::World[object.world_id].chain.map do |dep_id|
          PgDiff::World[dep_id]["model"]
        end
      end
    end
  end
end