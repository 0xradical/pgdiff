module PgDiff
  module Models
    class Unmapped < Base
      def initialize(objid, name, world_type, origin)
        @name, @world_type = name, world_type
        super({ "objid" => objid, "origin" => origin })
      end

      def name; @name; end
      def world_type; @world_type; end

      def to_s
        "UNMAPPED (#{world_type} #{name})"
      end

      def gid
        "#{world_type} #{name}"
      end

      def add
        return "" if system?

        super
      end

      def remove
        return "" if system?

        super
      end

      def system?
        return true if name =~ /\A(pg_toast)\./
        return true if gid =~ /OPERATOR public\./

        false
      end
    end
  end
end