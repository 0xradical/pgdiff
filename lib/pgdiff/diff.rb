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
      object.dependencies.i_depend_on.normal.referenced.each {|o| @added.add(o) }
      @added.add(object)
      # return if @added[object]
      # @added[object] = true
      # puts "ADD #{object.class} #{object.name} #{level}"
      # # @operations << object.add(self)
      # object.depends_on.each do |depends_on|
      #   puts "#{object.name} depend on #{depends_on.name}"
      #   add(depends_on, level + 1)
      # end
      # object.dependencies.each{ |dependency| add(dependency, level + 1) }
    end

    def remove(object)
      object.dependencies.others_depend_on_me.internal.objects.each{|o| @removed.add(o) }
      object.dependencies.others_depend_on_me.normal.objects.each{|o| @removed.add(o) }
      @removed.add(object)
      # return if @removed[object]
      # object.dependencies.each{ |dependency| remove(dependency) }
      # @operations << object.remove(self)
      # @removed[object] = true
    end

    def change(target, source)
      return if @changed[source]
      @operations << source.change(self, target)
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