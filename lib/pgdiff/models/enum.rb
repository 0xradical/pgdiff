module PgDiff
  module Models
    class Enum < Base
      def name
        "#{schema}.#{@data['name']}"
      end

      def id
        "ENUM #{name} #{elements}"
      end
    end
  end
end

# [{"schema"=>"app", "name"=>"api_key_status", "elements"=>"{enabled,disabled,blacklisted}"}]