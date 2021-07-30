module PgDiff
  module Models
    class Schema < Base
      def name
        nspname
      end

      def to_s
        "SCHEMA #{nspname}"
      end

      def world_type
        "SCHEMA"
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