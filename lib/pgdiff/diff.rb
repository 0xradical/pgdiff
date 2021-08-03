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

      sql += tree.add.reduce("") do |acc, (gid, _)|
        object = source.find_by_gid(gid)

        if object.nil? || object.add.empty?
          acc
        else
          acc += %Q{
      -- Adding #{gid.inspect}
      #{object.add}

          }
        end
      end
    end
  end
end