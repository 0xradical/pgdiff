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

    attr_reader :database, :objects, :classes, :dependencies, :prerequisites,
                :roles, :schemas, :tables, :views,
                :columns, :privileges,
                :functions, :aggregates, :sequences,
                :domains, :domain_constraints, :enums, :types, :extensions, :triggers,
                :indexes, :constraints, :gids, :unmapped, :rules

    def initialize(database)
      @database           =  database
      @objects            =  Hash.new
      @gids               =  Hash.new
      @classes            =  Hash.new
      @dependencies       =  Hash.new
      @prerequisites      =  Hash.new
      @roles              =  Hash.new
      @schemas            =  Hash.new
      @tables             =  Hash.new
      @views              =  Hash.new
      @functions          =  Hash.new
      @aggregates         =  Hash.new
      @sequences          =  Hash.new
      @domains            =  Hash.new
      @columns            =  Hash.new
      @privileges         =  Hash.new
      @domain_constraints =  Hash.new
      @enums              =  Hash.new
      @types              =  Hash.new
      @extensions         =  Hash.new
      @triggers           =  Hash.new
      @unmapped           =  Hash.new
      @constraints        =  Hash.new
      @indexes            =  Hash.new
      @rules              =  Hash.new
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
      @prerequisites[dependency.object.gid]      ||= []
      @dependencies[dependency.referenced.gid] ||= []
      if !@prerequisites[dependency.object.gid].include?(dependency.referenced.gid)
        @prerequisites[dependency.object.gid] << dependency.referenced.gid
      end
      if !@dependencies[dependency.referenced.gid].include?(dependency.object.gid)
        @dependencies[dependency.referenced.gid] << dependency.object.gid
      end
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
    def add_tablecolumn(column)
      @columns[column.gid] ||= column
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
    def add_domainconstraint(domain_constraint)
      @domain_constraints[domain_constraint.name] ||= domain_constraint
    end
    def add_enum(enum)
      @enums[enum.name] ||= enum
    end
    def add_type(type)
      @types[type.name] ||= type
    end
    def add_rule(rule)
      @rules[rule.name] ||= rule
    end
    def add_extension(extension)
      @extensions[extension.name] ||= extension
    end
    def add_trigger(trigger)
      @triggers[trigger.name] ||= trigger
    end
    def add_tableindex(index)
      @indexes[index.name] ||= index
    end
    def add_tableconstraint(constraint)
      @constraints[constraint.name] ||= constraint
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

    def find_by_gid(gid)
      @objects[@gids[gid]] || @columns[gid]
    end

    def find(object)
      find_by_gid(object.gid)
    end

    def dependencies_graph
      return @dependencies_graph if @graph

      error = nil
      begin
        graph = Dagwood::DependencyGraph.new(@dependencies)
        graph.order
        @dependencies_graph = graph
      rescue TSort::Cyclic => e
        error = e
        cycle = eval(error.message.gsub("topological sort failed:",""))
        @dependencies.delete(cycle.first)
        retry
      end
    end

    def dependencies_subgraph_for(gid)
      dependencies_graph.subgraph(gid)
    end

    def prerequisites_graph
      return @prerequisites_graph if @graph

      error = nil
      begin
        graph = Dagwood::DependencyGraph.new(@prerequisites)
        graph.order
        @prerequisites_graph = graph
      rescue TSort::Cyclic => e
        error = e
        cycle = eval(error.message.gsub("topological sort failed:",""))
        @prerequisites.delete(cycle.first)
        retry
      end
    end

    def prerequisites_subgraph_for(gid)
      prerequisites_graph.subgraph(gid)
    end
  end
end