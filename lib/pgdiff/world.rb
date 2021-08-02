module PgDiff
  module World
    extend self
    # maps object.identity to model
    OBJECTS      = Hash.new
    DEPENDENCIES = Hash.new
    ROLES        = Hash.new

    def add_dependency(dependency)
      DEPENDENCIES[dependency.hash] ||= dependency
    end

    def add_role(role)
      ROLES[role.name] ||= role
    end
  end
end