module PgDiff
  class Catalog
    include Enumerable

    attr_reader :roles, :schemas, :tables, :views,
                :functions, :aggregates, :sequences,
                :domains, :enums, :custom_types, :extensions, :triggers

    def initialize(connection, label = "unknown")
      @connection = connection
      @query = PgDiff::Queries.new(connection, label)
      collect_objects!
    end

    def collect_objects!
      @roles = @query.roles.map do |data|
        Models::Role.new(data)
      end
      @schemas = @query.schemas.map do |data|
        Models::Schema.new(data)
      end
      @extensions = @query.extensions.map do |data|
        Models::Extension.new(data)
      end
      @tables = @query.tables.map do |data|
        Models::Table.new(data).tap do |table|
          table.add_columns(@query.table_columns(table.name))
          table.add_constraints(@query.table_constraints(table.name))
          table.add_indexes(@query.table_indexes(table.name))
          table.add_options(@query.table_options(table.name))
          table.add_privileges(@query.table_privileges(table.name))
        end
      end
      @views = @query.views.map do |data|
        Models::View.new(data, false).tap do |view|
          view.add_privileges(@query.view_privileges(view.name))
        end
      end + @query.materialized_views.map do |data|
        Models::View.new(data, true).tap do |view|
          view.add_privileges(@query.materialized_view_privileges(view.name))
        end
      end
      @functions = @query.functions.map do |data|
        Models::Function.new(data).tap do |function|
          function.add_privileges(@query.function_privileges(function.name, function.argtypes))
        end
      end
      @aggregates = @query.aggregates.map do |data|
        Models::Aggregate.new(data)
      end
      @sequences = @query.sequences.map do |data|
        Models::Sequence.new(data).tap do |sequence|
          sequence.add_privileges(@query.sequence_privileges(sequence.name))
        end
      end
      @enums = @query.enums.map do |data|
        Models::Enum.new(data)
      end
      @domains = @query.domains.map do |data|
        Models::Domain.new(data).tap do |domain|
          domain.add_constraints(@query.domain_constraints(domain.name))
        end
      end
      @custom_types = @query.custom_types.map do |data|
        Models::CustomType.new(data)
      end
      @triggers = @query.triggers.map do |data|
        Models::Trigger.new(data)
      end
    end

    # deep each (every object and its attributes)
    def each_object(deep: true)
      [
        @roles, @schemas, @extensions, @enums,
        @domains, @custom_types, @aggregates, @tables,
        @views, @functions, @sequences, @triggers
      ].each do |family|
        family.each do |parent|
          yield parent
          if deep
            parent.each { |child| yield child }
          end
        end
      end
    end

    def include?(object)
      !!find(object)
    end

    def find(object)
      case object.class.name
      when "PgDiff::Models::Schema"
        schemas.select{|o| o.gid == object.gid }.first
      when "PgDiff::Models::Role"
        roles.select{|o| o.gid == object.gid }.first
      when "PgDiff::Models::Extension"
        extensions.select{|o| o.gid == object.gid }.first
      when "PgDiff::Models::Enum"
        enums.select{|o| o.gid == object.gid }.first
      when "PgDiff::Models::Domain"
        domains.select{|o| o.gid == object.gid }.first
      when "PgDiff::Models::Rule"
        rules.select{|o| o.gid == object.gid }.first
      when "PgDiff::Models::Aggregate"
        aggregates.select{|o| o.gid == object.gid }.first
      when "PgDiff::Models::Table"
        tables.select{|o| o.gid == object.gid }.first
      when "PgDiff::Models::View"
        views.select{|o| o.gid == object.gid }.first
      when "PgDiff::Models::Function"
        functions.select{|o| o.gid == object.gid }.first
      when "PgDiff::Models::Sequence"
        sequences.select{|o| o.gid == object.gid }.first
      else
        nil
      end
    end
  end
end