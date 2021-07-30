module PgDiff
  module Models
    class TableIndex < Base
      attr_reader :table

      def initialize(data, domain)
        super(data)
        @table = table
      end
    end
  end
end
