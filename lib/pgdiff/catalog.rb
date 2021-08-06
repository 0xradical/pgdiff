module PgDiff
  class Catalog
    include Enumerable

    def initialize(connection, label = "unknown")
      @connection = connection
      @query = PgDiff::Queries.new(connection, label)
      @world = PgDiff::World[label]
      collect_objects!
    end

    def collect_objects!
      @query.roles.each do |data|
        @world.add_object(data, Models::Role)
      end
      @query.schemas.each do |data|
        @world.add_object(data, Models::Schema)
      end
      @query.extensions.each do |data|
        @world.add_object(data, Models::Extension)
      end
      @query.tables.map do |data|
        @world.add_object(data, Models::Table)
      end
      @query.table_privileges.map do |data|
        @world.add_object(data, Models::TablePrivilege)
      end
      @query.table_columns.map do |data|
        @world.add_object(data, Models::TableColumn)
      end
      @query.view_dependencies.map do |data|
        @world.add_object(data, Models::Rule)
      end
      @query.views.map do |data|
        @world.add_object(data, Models::View)
      end
      @query.view_privileges.map do |data|
        @world.add_object(data, Models::ViewPrivilege)
      end
      @query.materialized_views.map do |data|
        @world.add_object(data, Models::View)
      end
      @query.materialized_view_privileges.map do |data|
        @world.add_object(data, Models::ViewPrivilege)
      end
      @query.functions.map do |data|
        @world.add_object(data, Models::Function)
      end
      @query.function_privileges.map do |data|
        @world.add_object(data, Models::FunctionPrivilege)
      end
      @query.aggregates.map do |data|
        @world.add_object(data, Models::Aggregate)
      end
      @query.sequences.map do |data|
        @world.add_object(data, Models::Sequence)
      end
      @query.sequence_privileges.map do |data|
        @world.add_object(data, Models::SequencePrivilege)
      end
      @query.enums.map do |data|
        @world.add_object(data, Models::Enum)
      end
      @query.domains.map do |data|
        @world.add_object(data, Models::Domain)
      end
      @query.domain_constraints.map do |data|
        @world.add_object(data, Models::DomainConstraint)
      end
      @query.types.map do |data|
        @world.add_object(data, Models::Type)
      end
      @query.triggers.map do |data|
        @world.add_object(data, Models::Trigger)
      end
    end
  end
end