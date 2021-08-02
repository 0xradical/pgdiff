module PgDiff
  class World
    @@worlds = Hash.new
    def self.[]=(id, world)
      @@worlds[id] = world
    end

    def self.[](id)
      @@worlds[id]
    end

    def self.method_missing(n)
      self[n.to_s]
    end

    attr_reader :objects, :classes, :dependencies, :roles, :schemas

    def initialize
      @objects      = Hash.new
      @classes      = Hash.new
      @dependencies = Hash.new
      @roles        = Hash.new
      @schemas      = Hash.new
    end

    # bag of objects coming from catalog
    # that will be used when querying dependencies
    def add_object(data, klass)
      if data["objid"]
        @objects[data["objid"]] = data
        @classes[data["objid"]] = klass
      end
    end

    def add_dependency(dependency)
      @dependencies[dependency.hash] ||= dependency
    end

    def add_role(role)
      @roles[role.name] ||= role
    end

    def add_schema(schema)
      @schemas[schema.name] ||= schema
    end
  end
end