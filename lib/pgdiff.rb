require "pg"

module PgDiff; end

require_relative "pgdiff/utils.rb"
require_relative "pgdiff/world.rb"
require_relative "pgdiff/queries.rb"
require_relative "pgdiff/models/base.rb"
require_relative "pgdiff/models/role.rb"
require_relative "pgdiff/models/type.rb"
require_relative "pgdiff/models/unmapped.rb"
require_relative "pgdiff/models/extension.rb"
require_relative "pgdiff/models/aggregate.rb"
require_relative "pgdiff/models/function_privilege.rb"
require_relative "pgdiff/models/function.rb"
require_relative "pgdiff/models/table_column.rb"
require_relative "pgdiff/models/table_constraint.rb"
require_relative "pgdiff/models/table_index.rb"
require_relative "pgdiff/models/table_option.rb"
require_relative "pgdiff/models/table_privilege.rb"
require_relative "pgdiff/models/table.rb"
require_relative "pgdiff/models/schema.rb"
require_relative "pgdiff/models/view_privilege.rb"
require_relative "pgdiff/models/view.rb"
require_relative "pgdiff/models/enum.rb"
require_relative "pgdiff/models/sequence_privilege.rb"
require_relative "pgdiff/models/sequence.rb"
require_relative "pgdiff/models/domain_constraint.rb"
require_relative "pgdiff/models/domain.rb"
require_relative "pgdiff/models/custom_type.rb"
require_relative "pgdiff/models/trigger.rb"
require_relative "pgdiff/catalog.rb"
require_relative "pgdiff/object.rb"
require_relative "pgdiff/dependency.rb"
require_relative "pgdiff/dependencies.rb"
require_relative "pgdiff/dependency_tree.rb"
require_relative "pgdiff/database.rb"
require_relative "pgdiff/diff.rb"

def PgDiff.compare(source, target)
  sql  = ""
  tree = PgDiff::DependencyTree.new
  tree.diff(source, target)

  # check for inconsistencies
  if (
      Set.new(tree.removed.keys) &
      Set.new(tree.added.keys) &
      Set.new(tree.changed.keys) &
      Set.new(tree.common.keys)
    ).count > 0
    raise "Cannot diff databases, conflicting operations"
  end

  sql += tree.add.reduce("") do |acc, (gid, _)|
    object = source.find_by_gid(gid)

    if object.nil? || object.add.empty?
      acc
    else
      acc += %Q{
  -- Adding #{object.name}
  #{object.add}

      }
    end
  end
end