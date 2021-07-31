module PgDiff
  class Diff
    attr_reader :operations, :added, :removed, :changed

    def initialize
      @operations = []
      @added = Hash.new(false)
      @removed = Hash.new(false)
      @changed = Hash.new(false)
    end

    def add(object, level = 0)
      return if @added[object]
      @added[object] = true
      puts "ADD #{object.class} #{object.name} #{level}"
      # @operations << object.add(self)
      object.depends_on.each do |depends_on|
        puts "#{object.name} depend on #{depends_on.name}"
        add(depends_on, level + 1)
      end
      object.dependencies.each{ |dependency| add(dependency, level + 1) }
    end

    def remove(object)
      return if @removed[object]
      object.dependencies.each{ |dependency| remove(dependency) }
      @operations << object.remove(self)
      @removed[object] = true
    end

    def change(target, source)
      return if @changed[source]
      @operations << source.change(self, target)
      # @operations << ["CHANGE", source.class, source.name]
    end
  end
end