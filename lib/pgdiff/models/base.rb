module PgDiff
  module Models
    class Base
      def initialize(data)
        @data = data
      end

      def id; @data; end
      def inspect; id; end

      def add
        raise "Not Implemented Error"
      end

      def drop
        raise "Not Implemented Error"
      end

      def change(to)
        raise "Not Implemented Error"
      end

      def method_missing(m, *a, &b)
        @data[m.to_s]
      end
    end
  end
end