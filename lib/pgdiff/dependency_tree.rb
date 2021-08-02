module PgDiff
  class DependencyTree
    attr_reader :nodes

    def initialize
      @nodes = []
      @processed = Hash.new(false)
    end

    def self.generate(world)
      tree = self.new

      world.objects.values.each do |object|
        tree.process(object)
      end

      tree.nodes
    end

    def process(node)
      return if @processed[node.gid]

      @processed[node.gid] = true
      node.dependencies.i_depend_on.referenced.each do |dependency|
        process(dependency)
      end
      @nodes << node
      node.dependencies.others_depend_on_me.objects.each do |dependency|
        process(dependency)
      end
    end
  end
end