module PgDiff
  module Models
    class TableIndex < Base
      attr_reader :table

      def initialize(data, table)
        super(data)
        @table = table
      end

      def name
        indexname
      end

      def definition
        indexdef
      end

      def world_type
        "INDEX"
      end

      def columns
        JSON.parse(columns_array)
      end

      def gid
        "TABLE INDEX #{indexname} ON #{table.name}"
      end

      def to_s
        "TABLE INDEX #{indexdef}"
      end

      def add
        # "#{indexdef};"
        ""
      end

      def remove
        # if there's a constraint for pkey don't do anything
        return "" if world.find_by_gid("TABLE CONSTRAINT #{indexname} ON #{table.name}")

        %Q{DROP INDEX #{identity};}
      end
    end
  end
end
