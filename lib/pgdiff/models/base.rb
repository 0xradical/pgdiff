module PgDiff
  module Models
    class Base
      # objid from pg_depend
      attr_accessor :id
      attr_accessor :depend_on
      attr_accessor :dependency_type

      def initialize(data)
        @data = data
      end

      def to_s; @data; end
      def inspect; to_s; end

      def add
        raise "Not Implemented In #{self.class.name} Error"
      end

      def drop
        raise "Not Implemented In #{self.class.name} Error"
      end

      def change(to)
        raise "Not Implemented In #{self.class.name} Error"
      end

      # identity from pg_identify_object
      def world_id
        identity
      end

      # type from pg_identify_object
      def world_type
        raise "Not Implemented In #{self.class.name} Error"
      end

      def each
        # NoOp
      end

      def method_missing(m, *a, &b)
        @data[m.to_s]
      end
    end
  end
end