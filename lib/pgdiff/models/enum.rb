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

      def add
        %Q{CREATE TYPE "#{name}" AS ENUM (\n} +
        elements[/\{(.*)\}/,1].split(/\s*,\s*/).map{|e| "'#{e}'"}.map do |element|
          " #{element}"
        end.join(",\n") +
        %Q{\n);}
      end
    end
  end
end

# [{"schema"=>"app", "name"=>"api_key_status", "elements"=>"{enabled,disabled,blacklisted}"}]