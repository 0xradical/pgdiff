module PgDiff
  module Models
    class Unmapped < Base
      def initialize(name, world_type)
        super({ })
        @name, @world_type = name, world_type
      end

      def name; @name; end
      def world_type; @world_type; end

      def to_s
        "UNMAPPED (#{name} #{world_type})"
      end

      def add
        ""
      end
    end
  end
end