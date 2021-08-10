module PgDiff
  module Models
    class Trigger < Base
      attr_accessor :table, :view

      def name
        "#{schema}.#{@data['name']}"
      end

      def to_s
        %Q{TRIGGER #{@data['name']} ON #{table_schema}.#{table_name} TO EXECUTE #{proc_schema}.#{proc_name}(#{proc_argtypes})}
      end

      def add
        %Q{#{definition};}
      end

      def ddl
        add
      end

      def gid
        definition
      end

      def remove
        %Q{DROP TRIGGER IF EXISTS #{@data['name']} ON #{table_schema}.#{table_name};}
      end

      def columns
        tgattr.split(/\s+/).map do |colidx|
          table.columns[colidx.to_i - 1]
        end
      rescue
        []
      end

      def function
        world.objects[tgfoid]
      end

      def world_type
        "TRIGGER"
      end
    end
  end
end
