module PgDiff
  module Models
    class CustomType < Base
      def initialize(data)
        super(data)
        # add dependencies artificially :/
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