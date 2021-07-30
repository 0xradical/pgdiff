module PgDiff
  module Models
    class Base
      def initialize(data)
        @data = data
      end

      def id; @data; end
      def inspect; id; end

      def method_missing(m, *a, &b)
        @data[m.to_s]
      end
    end
  end
end