module PgDiff
  module Models
    class TableOption < Base
      attr_reader :table

      def initialize(data, table)
        super(data)
        @table = table
      end

      def has_oid?
        relhasoids == 't'
      end

      def world_type
        "TABLE OPTION"
      end

      def world_id
        name
      end

      def to_s
        "TABLE OPTION #{has_oid? ? 'HAS OID' : 'DOES NOT HAVE OID'}"
      end
    end
  end
end
