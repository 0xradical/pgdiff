module PgDiff
  module Models
    class Schema < Base
      def name
        nspname
      end

      def id
        "SCHEMA #{nspname}"
      end

      def add
        %Q{CREATE SCHEMA IF NOT EXISTS "#{nspname}";}
      end

      def drop
        %Q{DROP SCHEMA "#{nspname}";}
      end
    end
  end
end