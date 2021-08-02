module PgDiff
  class Dependencies
    attr_reader :set, :object

    def initialize(object, initial_set = Set.new)
      @object = object
      @set = Set.new(initial_set)
    end

    def add(dependency)
      @set.add(dependency)
    end

    # normal:
    #   obj can be dropped without affecting ref
    #   ref can be dropped only with CASCADE
    # internal:
    #   obj cannot be dropped without affecting ref
    #   ref can only be dropped if obj is dropped first
    # automatic:
    #   obj can be dropped without affecting ref
    #   ref can be dropped (objs will be automatically dropped)
    # oncreate:
    #   obj can be dropped without affecting ref
    #   ref can be dropped (objs will be automatically dropped)
    #   obj must be created on ref creation
    def by_type(type)
      self.class.new(object, @set.select{|dep| dep.type == type})
    end

    def automatic
      self.class.new(object, by_type("automatic").set)
    end

    def normal
      self.class.new(object, by_type("normal").set)
    end

    def internal
      self.class.new(object, by_type("internal").set)
    end

    def oncreate
      self.class.new(object, by_type("oncreate").set)
    end

    def i_depend_on
      self.class.new(object, @set.select{|dep| dep.object == self.object })
    end

    def others_depend_on_me
      self.class.new(object, @set.select{|dep| dep.referenced == self.object })
    end

    def objects
      @set.map(&:object)
    end

    def referenced
      @set.map(&:referenced)
    end
  end
end
