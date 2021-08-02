module PgDiff
  class World
    @@worlds = Hash.new
    def self.[]=(id, world)
      @@worlds[id] = world
    end

    def self.[](id)
      @@worlds[id]
    end

    attr_reader :objects, :dependencies, :roles

    def initialize
      @objects = Hash.new
      @dependencies = Hash.new
      @roles = Hash.new
    end

    def add_object(object, id = nil)
      _id = id || object.objid
      raise "ID cannot be Nil: #{object.name} does not have objid" if _id.nil?
      @objects[_id] = object
    end

    def add_dependency(dependency)
      @dependencies[dependency.hash] ||= dependency
    end

    def add_role(role)
      @roles[role.name] ||= role
    end
  end
end