module PgDiff
  class DependencyTree
    attr_reader :add, :remove, :change

    def initialize
      @add     = Hash.new(false)
      @remove  = Hash.new(false)
      @change  = Hash.new(false)
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

      parents.sort_by{|k,v| v.length}.map(&:first).reject{|n| n.gid == node.gid }
    end

    def _create_deps(node, p = [], c = Set.new)
      return if p.include?(node)

      c.add(p + [node])

      node.dependencies.others_depend_on_me.oncreate.objects.each do |dependency|
        _create_deps(dependency, p + [node], c)
      end
    end

    def create_deps(node)
      p = []
      c = Set.new
      _create_deps(node, p, c)
      children = Hash.new

      c.each do |chain|
        0.upto(chain.length - 1) do |idx|
          children[chain[idx]] ||= Set.new
          children[chain[idx]]  = children[chain[idx]] | Set.new(chain[idx..-1])
        end
      end

      children.each{|k,v| v.delete(k) }

      children.sort_by{|k,v| v.length}.map(&:first).reject{|n| n.gid == node.gid }
    end

    def _remove_deps(node, p = [], c = Set.new)
      return if p.include?(node)

      c.add(p + [node])

      node.dependencies.others_depend_on_me.internal.objects.each do |dependency|
        _remove_deps(dependency, p + [node], c)
      end
    end

    def remove_deps(node)
      p = []
      c = Set.new
      _remove_deps(node, p, c)
      children = Hash.new

      c.each do |chain|
        0.upto(chain.length - 1) do |idx|
          children[chain[idx]] ||= Set.new
          children[chain[idx]]  = children[chain[idx]] | Set.new(chain[idx..-1])
        end
      end

      children.each{|k,v| v.delete(k) }

      children.sort_by{|k,v| v.length}.map(&:first).reject{|n| n.gid == node.gid }
    end

    def _add(node)
      return if @add[node.gid]

      priors(node).each do |prior|
        @add[prior.gid] = true
        _add(prior)
      end

      @add[node.gid] = true

      create_deps(node).each do |dep|
        @add[dep.gid] = true
        _add(dep)
      end
    end

    def _remove(node)
      return if @remove[node.gid]

      remove_deps(node).each do |prior|
        @remove[prior.gid] = true
        _remove(prior)
      end

      @remove[node.gid] = true
    end

    def diff(source, target)
      # Add these
      puts "Initiating diff"

      puts "Fetching objects from source that should be added to target"
      to_be_added = Set.new(source.objects.values.map(&:gid)) - Set.new(target.objects.values.map(&:gid))
      to_be_added.each do |added_gid|
        _add(source.find_by_gid(added_gid))
      end

      # Remove these
      puts "Fetching objects from source that should be removed from target"
      to_be_removed = Set.new(target.objects.values.map(&:gid)) - Set.new(source.objects.values.map(&:gid))
      to_be_removed.each do |removed_gid|
        _remove(target.find_by_gid(removed_gid))
      end

      # Change these
      puts "Fetching common objects that changed"
      common = Set.new(source.objects.values.map(&:gid)) & Set.new(target.objects.values.map(&:gid))

      common.each do |common_object_gid|
        sobject = source.find_by_gid(common_object_gid)
        tobject = target.find_by_gid(common_object_gid)

        if tobject.to_s != sobject.to_s
          @change[sobject.gid] = true
        end
      end

      PgDiff::Diff.new(self, source, target) unless conflict?(source, target)
    end

    def conflict?(source, target)
      common = Set.new(source.objects.values.map(&:gid)) & Set.new(target.objects.values.map(&:gid))

      # Don't add or remove common objects
      common.to_a.each{|c| @add.delete(c); @remove.delete(c) }

      raise "Objects cannot be added and removed" if (Set.new(add.keys) & Set.new(remove.keys)).count > 0
      raise "Common objects cannot be added"  if (Set.new(add.keys) & common).count > 0
      raise "Common objects cannot be removed" if (Set.new(remove.keys) & common).count > 0
      raise "Objects cannot be added and changed" if (Set.new(add.keys) & Set.new(change.keys)).count > 0
      raise "Objects cannot be removed and changed" if (Set.new(remove.keys) & Set.new(change.keys)).count > 0

      false
    end
  end
end