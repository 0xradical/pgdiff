module PgDiff
  module Models
    class CustomType < Base
      def initialize(data)
        super(data)
        # add dependencies artificially :/
        columns.each do |column|
          if !world.objects[column['objid']]
            world.add_object(
              PgDiff::Models::Type.new({
                "objid" => column['objid'],
                "type" => column['type'],
                "identity" => column["identity"]
              })
            )
          end

          world.add_dependency(
            PgDiff::Dependency.new(
              self,
              world.objects[column['objid']],
              "internal"
            )
          )
        end
      end

      def world_type
        "TYPE"
      end

      def name
        "#{schema}.#{internal_name}"
      end

      def to_s
        %Q{CUSTOM TYPE #{name} #{columns}}
      end

      def columns
        JSON.parse(@data['columns'])
      end

      def add(diff)
        %Q{CREATE TYPE #{name} AS (\n}+
        columns.map do |column|
          %Q{   #{column['attribute']} #{column['type']}}
        end.join(",\n") +
        %Q{\n);}
      end
    end
  end
end

# schema
# name
# internal_name
# size
# columns
# description
# identity
# objid