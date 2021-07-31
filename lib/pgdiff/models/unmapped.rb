module PgDiff
  module Models
    class Unmapped < Base
      def initialize(objid, name, world_type)
        super({ "objid" => objid })
        @name, @world_type = name, world_type
      end

      def name; @name; end
      def world_type; @world_type; end

      def to_s
        "UNMAPPED (#{world_type} #{name})"
      end

      def add(diff)
        ""
      end
    end
  end
end