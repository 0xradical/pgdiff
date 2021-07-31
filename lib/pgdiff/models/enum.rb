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

      def change(diff, from)
        dependencies.map do |d|
          d.to_s
        end.join("\n")
        # elements.each do |element|

        # end
      end

      def elements
        @data['elements'][/\{(.*)\}/,1].split(/\s*,\s*/)
      end

      def add(diff)
        %Q{CREATE TYPE "#{name}" AS ENUM (\n} +
        elements.map{|e| "'#{e}'"}.map do |element|
          " #{element}"
        end.join(",\n") +
        %Q{\n);}
      end
    end
  end
end

# [{"schema"=>"app", "name"=>"api_key_status", "elements"=>"{enabled,disabled,blacklisted}"}]