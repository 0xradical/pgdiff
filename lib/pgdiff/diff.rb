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

    def change(object, to)
      @operations << object.change(to)
    end
  end
end