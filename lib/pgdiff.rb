require "pg"

module PgDiff; end

require_relative "pgdiff/utils.rb"
require_relative "pgdiff/world.rb"
require_relative "pgdiff/queries.rb"
require_relative "pgdiff/models/base.rb"
require_relative "pgdiff/models/role.rb"
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
require_relative "pgdiff/database.rb"
require_relative "pgdiff/diff.rb"

def PgDiff.compare(source, target)
  diff = PgDiff::Diff.new
  # source.catalog.each_object(deep: false) do |sobject|
  #   diff.add(sobject)
  # end

  # target.catalog.each_object(deep: false) do |tobject|
  #   diff.remove(tobject)
  # end


  # source.catalog.each_object(deep: false) do |sobject|
  #   tobject = target.catalog.find(sobject)

  #   if tobject
  #     if tobject.to_s != sobject.to_s
  #       # diff.change(tobject, sobject)
  #     end
  #   else
  #     diff.add(sobject)
  #   end
  # end

  # target.catalog.each_object(deep: false) do |object|
  #   if !source.catalog.include?(object)
  #     diff.remove(object)
  #   end
  # end

  diff
end