module PgDiff
  module Models
    class Trigger < Base
      def name
        "#{schema}.#{@data['name']}"
      end

      def to_s
        %Q{TRIGGER #{name} ON #{table_schema}.#{table_name} TO EXECUTE #{proc_schema}.#{proc_name}(#{proc_argtypes})}
      end

      def add(diff)
        %Q{#{definition};}
      end

      def world_type
        "TRIGGER"
      end
    end
  end
end
