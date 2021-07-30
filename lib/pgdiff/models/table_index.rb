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

      def id
        "TABLE INDEX #{indexdef}"
      end

      def add
        indexdef
      end
    end
  end
end
