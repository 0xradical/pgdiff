module PgDiff
  class Catalog
    include Enumerable

    attr_reader :roles, :schemas, :tables, :views,
                :functions, :aggregates, :sequences,
                :domains, :enums, :types, :extensions, :triggers

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
      @query.views.map do |data|
        @world.add_object(data, Models::View)
      end
      @query.materialized_views.map do |data|
        @world.add_object(data, Models::View)
      end
      @query.functions.map do |data|
        @world.add_object(data, Models::Function)
      end
      @query.aggregates.map do |data|
        @world.add_object(data, Models::Aggregate)
      end
      @query.sequences.map do |data|
        @world.add_object(data, Models::Sequence)
      end
      @query.enums.map do |data|
        @world.add_object(data, Models::Enum)
      end
      @query.domains.map do |data|
        @world.add_object(data, Models::Domain)
      end
      @query.types.map do |data|
        @world.add_object(data, Models::Type)
      end
      @query.triggers.map do |data|
        @world.add_object(data, Models::Trigger)
      end
    end

    # deep each (every object and its attributes)
    def each_object(deep: true)
      [
        @roles, @schemas, @extensions, @enums,
        @domains, @types, @aggregates, @tables,
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