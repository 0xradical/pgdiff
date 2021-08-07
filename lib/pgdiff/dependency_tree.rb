module PgDiff
  class DependencyTree
    attr_reader :add, :remove, :change

    def initialize
      @add     = Hash.new(false)
      @remove  = Hash.new(false)
      @change  = Hash.new(false)

      # last operation
      @lastop  = Hash.new(:noop)
      @ops     = []
    end

    def self._prerequisites(node, p = [], c = Set.new)
      return if p.include?(node)

      c.add(p + [node])

      node.dependencies.i_depend_on.referenced.each do |dependency|
        self._prerequisites(dependency, p + [node], c)
      end
    end

    def self.prerequisites(node)
      p = []
      c = Set.new
      _prerequisites(node, p, c)
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

    def self._dependencies(node, p = [], c = Set.new, condition = proc {})
      return if p.include?(node)

      c.add(p + [node])

      node.dependencies.others_depend_on_me.by_condition(condition).objects.each do |dependency|
        self._dependencies(dependency, p + [node], c, condition)
      end
    end

    def self.dependencies(node, condition = proc {})
      p = []
      c = Set.new
      _dependencies(node, p, c, condition)
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

    def _add(node, added = Hash.new(0))
      return if added[node.gid] > 1

      self.class.prerequisites(node).each do |prior|
        added[prior.gid] += 1
        _add(prior, added)
      end

      added[node.gid] += 1

      self.class.dependencies(node, proc{|d| d.type == "oncreate" }).each do |dep|
        added[dep.gid] += 1
        _add(dep, added)
      end
    end

    def _remove(node, removed = Hash.new(0))
      return if removed[node.gid] > 1

      self.class.dependencies(node, proc{|d| true }).map do |prior|
        removed[prior.gid] += 1
        _remove(prior, removed)
      end

      removed[node.gid] += 1
    end

    def tree_for(world)
      added = Hash.new(0)

      world.objects.values.map do |node|
        _add(node, added)
      end

      added
    end

    def _diff(source, target)
      plan = Hash.new

      tree_for(source).keys.each do |gid|
        sobject = source.find_by_gid(gid)
        tobject = target.find_by_gid(gid)

        if sobject && tobject
          if tobject.to_s != sobject.to_s
            plan[gid] = :change
          end
        elsif sobject
          plan[gid] = :add
        else
          plan[gid] = :remove
        end
      end

      tree_for(target).keys.each do |gid|
        sobject = source.find_by_gid(gid)

        if !sobject && !plan[gid]
          plan[gid] = :remove
        end
      end

      plan
    end

    def diff(source, target)
      @ops = []

      puts "Initiating diff"
      binding.pry
      common        = Set.new(source.objects.values.map(&:gid)) & Set.new(target.objects.values.map(&:gid))
      to_be_added   = Set.new(source.objects.values.map(&:gid)) - Set.new(target.objects.values.map(&:gid))
      to_be_removed = Set.new(target.objects.values.map(&:gid)) - Set.new(source.objects.values.map(&:gid))

      # Change these
      puts "Fetching common objects that changed"
      common.each do |common_object_gid|
        sobject = source.find_by_gid(common_object_gid)
        tobject = target.find_by_gid(common_object_gid)

        if tobject.to_s != sobject.to_s
          sobject.changeset(tobject).each do |gid, options|
            case options[:op]
            when :add
              _add(source.find_by_gid(gid))
            when :remove
              _remove(target.find_by_gid(gid))
            when :rename
              self.class.dependencies(target.find_by_gid(gid), proc{|d| true }).each do |prior|
                set_op(prior, :remove)
                _remove(prior)
              end

              set_op(source.find_by_gid(options[:name]), options[:op], { from: target.find_by_gid(gid) })

              self.class.dependencies(source.find_by_gid(options[:name]), proc{|d| true }).each do |dep|
                set_op(dep, :add)
                _add(dep)
              end
            else
              set_op(source.find_by_gid(gid), options[:op], { from: target.find_by_gid(gid) })
            end
          end
        end
      end

      # Add these
      puts "Fetching objects from source that should be added to target"
      to_be_added.each do |added_gid|
        _add(source.find_by_gid(added_gid))
      end

      # Remove these
      puts "Fetching objects from source that should be removed from target"
      to_be_removed.each do |removed_gid|
        _remove(target.find_by_gid(removed_gid))
      end
      @ops
      # PgDiff::Diff.new(self, source, target)
    end
  end
end