module PgDiff
  module Models
    class Type < Base
      def world_type
        "TYPE"
      end

      def name
        identity
      end

      def gid
        to_s
      end

      def to_s
        %Q{TYPE #{name}}
      end

      def columns
        JSON.parse(@data['columns'])
      end

      def add
        return "" if category == "A"
        return "" if columns.empty?

        %Q{CREATE TYPE #{name} AS (\n}+
        columns.map do |column|
          %Q{   #{column['attribute']} #{column['type']}}
        end.join(",\n") +
        %Q{\n);}
      end
    end
  end
end
