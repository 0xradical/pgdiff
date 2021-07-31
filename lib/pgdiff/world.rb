module PgDiff
  module World
    extend self
    # maps object.identity to model
    OBJECTS      = Hash.new
    DEPENDENCIES = Hash.new

    def add_dependency(dependency)
      DEPENDENCIES[dependency.hash] ||= dependency
    end
  end
end