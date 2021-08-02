module PgDiff
  class World
    @@worlds = Hash.new
    def self.[]=(id, world)
      @@worlds[id] = world
    end

    def self.[](id)
      @@worlds[id]
    end

    def self.method_missing(n)
      self[n.to_s]
    end

    attr_reader :objects, :classes, :dependencies,
                :roles, :schemas, :tables, :views,
                :functions, :aggregates, :sequences,
                :domains, :enums, :types, :extensions, :triggers

    def initialize
      @objects      = Hash.new
      @classes      = Hash.new
      @dependencies = Hash.new
      @roles        = Hash.new
      @schemas      = Hash.new
      @tables       = Hash.new
      @views        = Hash.new
      @functions    = Hash.new
      @aggregates   = Hash.new
      @sequences    = Hash.new
      @domains      = Hash.new
      @enums        = Hash.new
      @types        = Hash.new
      @extensions   = Hash.new
      @triggers     = Hash.new
      @unmapped     = Hash.new
    end

    # bag of objects coming from catalog
    # that will be used when querying dependencies
    def add_object(data, klass)
      if data["objid"]
        @objects[data["objid"]] = data
        @classes[data["objid"]] = klass
      end
    end

    def add_dependency(dependency)
      @dependencies[dependency.hash] ||= dependency
    end
    def add_role(role)
      @roles[role.name] ||= role
    end
    def add_schema(schema)
      @schemas[schema.name] ||= schema
    end
    def add_table(table)
      @tables[table.name] ||= table
    end
    def add_view(view)
      @views[view.name] ||= view
    end
    def add_function(function)
      @functions[function.name] ||= function
    end
    def add_aggregate(aggregate)
      @aggregates[aggregate.name] ||= aggregate
    end
    def add_sequence(sequence)
      @sequences[sequence.name] ||= sequence
    end
    def add_domain(domain)
      @domains[domain.name] ||= domain
    end
    def add_enum(enum)
      @enums[enum.name] ||= enum
    end
    def add_type(type)
      @types[type.name] ||= type
    end
    def add_extension(extension)
      @extensions[extension.name] ||= extension
    end
    def add_trigger(trigger)
      @triggers[trigger.name] ||= trigger
    end
    def add_unmapped(unmapped)
      @unmapped[unmapped.name] ||= unmapped
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