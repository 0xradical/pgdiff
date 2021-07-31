module PgDiff
  class Diff
    attr_reader :operations

    def initialize
      @operations = []
    end

    def add(object)
      @operations << object.add
    end

    def drop(object)
      @operations << object.drop
    end

    def change(target, source)
      @operations << target.change(source)
    end
  end
end