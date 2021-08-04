module PgDiff
  module Models
    class Enum < Base
      def name
        "#{schema}.#{@data['name']}"
      end

      def world_type
        "TYPE"
      end

      def to_s
        "ENUM #{name} #{elements}"
      end

      def change(from)
        super
        # dependencies.map do |d|
        #   d.to_s
        # end.join("\n")
        # elements.each do |element|

        # end
      end

      def elements
        @data['elements'][/\{(.*)\}/,1].split(/\s*,\s*/)
      end

      def add
        return "" if from_extension == "t"

        %Q{CREATE TYPE #{name} AS ENUM (\n} +
        elements.map{|e| "'#{e}'"}.map do |element|
          " #{element}"
        end.join(",\n") +
        %Q{\n);}
      end

      def remove
        return "" if from_extension == "t"

        %Q{DROP TYPE #{name};}
      end
    end
  end
end

# [{"schema"=>"app", "name"=>"api_key_status", "elements"=>"{enabled,disabled,blacklisted}"}]