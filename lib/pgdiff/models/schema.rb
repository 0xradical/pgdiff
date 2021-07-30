module PgDiff
  module Models
    class Schema < Base
      def name
        nspname
      end

      def id
        nspname
      end
    end
  end
end