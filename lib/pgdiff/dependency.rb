module PgDiff
  class Dependency
    attr_reader :object, :referenced, :type

    def initialize(object, referenced, type)
      @object, @referenced, @type = object, referenced, type
      @object.add_dependency(self)
      @referenced.add_dependency(self)
    end

    def eql?(other)
      @object.id == other.object.id &&
      @referenced.id == other.referenced.id
    end

    def hash
      "#{@object.id}00000#{@referenced.id}".to_i
    end
  end
end