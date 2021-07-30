module PgDiff
  module Models
    class Base
      def initialize(data)
        @data = data
      end

      def to_s; @data; end
      def inspect; to_s; end

      def add
        raise "Not Implemented Error"
      end

      def drop
        raise "Not Implemented Error"
      end

      def change(to)
        raise "Not Implemented Error"
      end

      # identity from pg_identify_object
      def world_id
        identity
      end

      # type from pg_identify_object
      def world_type
        raise "Not Implemented Error"
      end

      # objid from pg_depend
      def id
        raise "Not Implemented Error"
      end

      def dependencies
        Pg::Diff::World[world_id] || []
      end

      def method_missing(m, *a, &b)
        @data[m.to_s]
      end
    end
  end
end