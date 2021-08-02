module PgDiff
  class DependencyTree
    attr_reader :add, :remove, :change,
                :added, :removed, :changed,
                :common

    def initialize
      @common  = Hash.new(false)
      @added   = Hash.new(false)
      @add     = Hash.new
      @removed = Hash.new(false)
      @remove  = Hash.new
      @changed = Hash.new(false)
      @change  = Hash.new
    end

    def add(node)
      return if @added[node.gid]
      return if @common[node.gid]

      @added[node.gid] = true

      node.dependencies.i_depend_on.referenced.each do |dependency|
        add(dependency)
      end

      @add[node.gid] = node

      # others that are internal are created automatically
      node.dependencies.others_depend_on_me.normal.objects.each do |dependency|
        add(dependency)
      end
    end

    def remove(node)
      return if @removed[node.gid]
      return if @common[node.gid]

      @removed[node.gid] = true

      node.dependencies.others_depend_on_me.internal.objects.each do |dependency|
        remove(node)
      end

      node.dependencies.others_depend_on_me.normal.objects.each do |dependency|
        remove(node)
      end

      @remove[node.gid] = node
    end

    def diff(source, target)
      # objects in common
      source.objects.values.select do |object|
        if (tobject = target.find(object)) && (tobject.to_s == object.to_s)
          @common[object.gid] = true
        end
      end

      # Add these
      source.objects.values.select do |object|
        if !target.find(object)
          add(object)
        end
      end

      # Remove these
      target.objects.values.select do |object|
        if !source.find(object)
          remove(object)
        end
      end

      # Change these
      # source.objects.values.select do |object|
      #   if (tobject = target.find(object)) && (tobject.to_s != object.to_s)

      #   end
      # end
    end
  end
end