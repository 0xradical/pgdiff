module PgDiff
  module Models
    class Type < Base
      def world_type
        "TYPE"
      end

      def name
        identity
      end

      def gid
        to_s
      end

      def to_s
        %Q{TYPE #{name}}
      end

      def add
        ""
      end
    end
  end
end
