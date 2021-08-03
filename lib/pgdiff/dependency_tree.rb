module PgDiff
  class DependencyTree
    attr_reader :add, :remove, :change,
                :added, :removed, :changed,
                :common

    def initialize
      @common  = Hash.new(false)
      @added   = Hash.new(false)
      @adding  = Hash.new(false)
      @add     = Hash.new(false)
      @removed = Hash.new(false)
      @remove  = Hash.new
      @changed = Hash.new(false)
      @change  = Hash.new
    end

    def _priors(node, p = [], c = Set.new)
      return if p.include?(node)

      c.add(p + [node])

      node.dependencies.i_depend_on.referenced.each do |dependency|
        _priors(dependency, p + [node], c)
      end
    end

    def priors(node)
      p = []
      c = Set.new
      _priors(node, p, c)
      parents = Hash.new

      c.each do |chain|
        0.upto(chain.length - 1) do |idx|
          parents[chain[idx]] ||= Set.new
          parents[chain[idx]]  = parents[chain[idx]] | Set.new(chain[idx..-1])
        end
      end

      parents.each{|k,v| v.delete(k) }

      parents.sort_by{|k,v| v.length}.map(&:first)
    end

    def _add(node)
      return if @common[node.gid]
      return if @add[node.gid]

      priors(node).each do |prior|
        @add[prior.gid] = true
        _add(prior)
      end

      @add[node.gid] = true
    end

    def _remove(node)
      return if @removed[node.gid]
      return if @common[node.gid]

      @removed[node.gid] = true

      node.dependencies.others_depend_on_me.internal.objects.each do |dependency|
        _remove(node)
      end

      node.dependencies.others_depend_on_me.normal.objects.each do |dependency|
        _remove(node)
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
          _add(object)
        end
      end

      # Remove these
      target.objects.values.select do |object|
        if !source.find(object)
          _remove(object)
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