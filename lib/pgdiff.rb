require "pg"

module PgDiff; end

require_relative "pgdiff/utils.rb"
require_relative "pgdiff/world.rb"
require_relative "pgdiff/models/base.rb"
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
require_relative "pgdiff/models/trigger.rb"
require_relative "pgdiff/catalog.rb"
require_relative "pgdiff/deps.rb"
require_relative "pgdiff/database.rb"
require_relative "pgdiff/diff.rb"

def PgDiff.compare(source, target)
  diff = PgDiff::Diff.new

  source.catalog.each_object(deep: false) do |object|
    if !target.catalog.include?(object)
      diff.add(object)
    end
  end

  target.catalog.each_object(deep: false) do |object|
    if !source.catalog.include?(object)
      diff.drop(object)
    end
  end

  diff.operations
end