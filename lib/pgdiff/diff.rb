module PgDiff
  class Diff
    attr_reader :tree, :source, :target

    def initialize(tree, source, target)
      @tree = tree
      @source = source
      @target = target
    end

    def to_sql
      sql = ""

      sql += tree.add.keys.reduce("") do |acc, gid|
        object = source.find_by_gid(gid)

        if object.nil?
          acc
        else
          clause = object.add

          if clause.empty?
            acc
          else
            acc += %Q{
-- Adding #{gid.inspect}
#{clause}
}
          end
        end
      end

      sql += tree.remove.keys.reverse.reduce("") do |acc, gid|
        object = target.find_by_gid(gid)

        if object.nil?
          acc
        else
          clause = object.remove

          if clause.empty?
            acc
          else
            acc += %Q{
-- Removing #{gid.inspect}
#{clause}
}
          end
        end
      end

      sql += tree.change.keys.reduce("") do |acc, gid|
        sobject = source.find_by_gid(gid)
        tobject = target.find_by_gid(gid)

        if sobject.nil? || tobject.nil?
          acc
        else
          clause = sobject.change(tobject)

          if clause.empty?
            acc
          else
            acc += %Q{
-- Changing #{gid.inspect}
#{clause}
}
          end
        end
      end
    end
  end
end