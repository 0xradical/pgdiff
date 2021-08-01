module PgDiff
  class Diff
    attr_reader :operations, :added, :removed, :changed

    def initialize
      @operations = []
      @added   = Set.new
      @removed = Set.new
      @changed = Set.new
    end

    def add(object)
      _add(object, 0)
    end

    def _add(object, level = 0)
      return if @added.member?(object)
      @added.add(object)

      object.dependencies.i_depend_on.normal.referenced.each {|o| _add(o, level + 1) }
      object.dependencies.i_depend_on.automatic.referenced.each {|o| _add(o, level + 1) }
    end

    def remove(object)
      removals = Set.new
      _remove(object, 0, removals)
      removals.to_a.reverse.each {|r| @removed.add(r) }
    end

    def _remove(object, level = 0, set = Set.new)
      return if set.member?(object)
      set.add(object)

      object.dependencies.others_depend_on_me.internal.objects.each{|o| _remove(o,level + 1, set) }
      object.dependencies.others_depend_on_me.normal.objects.each{|o| _remove(o,level + 1, set) }
    end

    def change(target, source)
      return if @changed[source]
      @changed.add(source.change(self, target))
      # @operations << source.change(self, target)
      # @operations << ["CHANGE", source.class, source.name]
    end

    def to_sql
      "\n\n\n" +
      @added.reduce("") do |acc, o|
        acc += "-- Adding #{o.name}\n"
        acc += o.add(self)
        acc += "\n"
        acc
      end +
      "\n\n\n" +
      @removed.reduce("") do |acc, o|
        acc += "-- Removing #{o.name}\n"
        acc += o.remove(self)
        acc += "\n"
        acc
      end
    end
  end
end