module PgDiff
  module Models
    class Base
      # objid from pg_depend
      attr_accessor :id
      attr_accessor :dependencies

      def initialize(data)
        @data = data
        @dependencies = PgDiff::Dependencies.new(self)
        world.public_send("add_#{model}", self) if world.respond_to?("add_#{model}")
      end

      def model
        self.class.name.split("::").last.downcase
      end

      def world
        PgDiff::World[origin]
      end

      def to_s; @data; end
      def inspect; to_s; end
      def objid; @data['objid'] || to_s; end
      def id; objid; end
      def gid
        "#{world_type} #{world_id}"
      end

      def add_dependency(dependency)
        @dependencies.add(dependency)
      end

      def ==(other)
        objid == other.objid
      end

      def add
        "
        -- Addition of #{self.class.name} (#{world_type} #{name}) not implemented
        "
      end

      def remove(diff)
        "
        -- Removal of #{self.class.name} (#{world_type} #{name}) not implemented
        "
      end

      def change(diff, from)
        "
        -- Changes to #{self.class.name} (#{world_type} #{name}) not implemented
        "
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