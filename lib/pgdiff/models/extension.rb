module PgDiff
  module Models
    class Extension < Base
      def name
        "#{schema}.#{@data['name']}"
      end

      def id
        "EXTENSION #{name}"
      end
    end
  end
end

# [{"schema"=>"app", "name"=>"api_key_status", "elements"=>"{enabled,disabled,blacklisted}"}]