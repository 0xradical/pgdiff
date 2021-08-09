require "pry"
module PgDiff
  class Diff
    SPACER = "\n"

    attr_reader :source, :target

    def initialize(source, target)
      @source  = source
      @target  = target
      @added   = Hash.new(false)
      @removed = Hash.new(false)
      @changed = Hash.new(false)
      @common  = Hash.new(false)
      @plan    = Hash.new{|h,k| h[k] = {:added=>false, :removed=>false, :changed=>false, :skipped => false, :position=>-1, :change => :noop}}
      @counter = 0
    end

    def add_plan(gid, operation, changeop = :noop)
      raise "GID is not a string" unless gid.is_a?(String)
      return if @plan[gid][:position] >= 0

      @plan[gid][operation] = true
      @plan[gid][:change]   = changeop
      @plan[gid][:position] = (@counter += 1)
    end

    def added?(gid)
      @plan[gid][:added]
    end

    def skipped?(gid)
      @plan[gid][:skipped]
    end

    def removed?(gid)
      @plan[gid][:removed]
    end

    def changed?(gid)
      @plan[gid][:changed]
    end

    def common?(gid)
      @common[gid]
    end

    def to_be_added(klass)
      (
        Set.new(source.public_send(klass).values.map(&:gid)) - Set.new(target.public_send(klass).values.map(&:gid))
      ).select{|gid| !added?(gid) }
    end

    def to_be_removed(klass)
      (
        Set.new(target.public_send(klass).values.map(&:gid)) - Set.new(source.public_send(klass).values.map(&:gid))
      ).select{|gid| !removed?(gid) }
    end

    def common(klass)
      (
        Set.new(source.public_send(klass).values.map(&:gid)) & Set.new(target.public_send(klass).values.map(&:gid))
      )
    end

    def to_be_changed(klass)
      common(klass).select{ |gid| !changed?(gid) }
    end

    def header(text)
      sql_line(%Q{-- #{text}})
    end

    def pending(gid, op, sql)
      sql << sql_line(%Q{-- == PENDING #{op} ON #{gid} ==})
      sql << %Q{
---- Before:
---- #{target.find_by_gid(gid).to_s.split("\n").map{|l| '-- ' + l}.join("\n")}
----
---- After:
---- #{source.find_by_gid(gid).to_s.split("\n").map{|l| '-- ' + l}.join("\n")}
}
    end

    def sql_line(line)
      line << SPACER
    end

    def add(gid, sql)
      return if skipped?(gid) || added?(gid) || common?(gid)

      node = source.find_by_gid(gid)
      if !node
        sql << header("Skipping #{gid}")
        add_plan(gid, :skipped)
        return
      end

      add_plan(gid, :added)

      if node.add.length > 0
        sql << header("Adding #{gid}")
        sql << sql_line(node.add)
      end

      node.dependencies.others_depend_on_me.by_type("oncreate").objects.each do |object|
        add(object.gid, sql)
      end
    end

    def remove(gid, sql)
      return if skipped?(gid) || removed?(gid) || common?(gid)

      node = target.find_by_gid(gid)
      if !node
        sql << header("Skipping #{gid}")
        add_plan(gid, :skipped)
        return
      end

      add_plan(gid, :removed)

      node.dependencies.others_depend_on_me.by_condition(proc{|d| d.type == "internal" || d.type == "normal"}).objects.each do |object|
        remove(object.gid, sql)
      end

      remove_TABLE_dependencies(node, sql) if node.class.name == "PgDiff::Models::Table"

      if node.remove.length > 0
        sql << header("Removing #{gid}")
        sql << sql_line(node.remove)
      end
    end

    def remove_TABLE_dependencies(table, sql)
      table.constraints.each do |ctt|
        if ctt.type == "PRIMARY KEY"
          # look for the columns , have they already been removed ?
          index = target.find_by_gid("TABLE INDEX #{ctt.name} ON #{table.name}")
          if index.columns.reduce(false) {|acc, col| acc || removed?("TABLE COLUMN #{col} ON #{table.name}") }
            add_plan(ctt.gid, :skipped)
          end
        end
        if ctt.type == "FOREIGN KEY"
          # if columns i referenced were removed...
          if ctt.pk_columns.reduce(false) {|acc, colidx| acc || removed?("TABLE COLUMN #{table.columns[colidx -1].name} ON #{table.name}") }
            add_plan(ctt.gid, :skipped)
          end
        end
        target.dependencies_subgraph_for(ctt.gid).order[0..-2].select do |dep|
          dep !~ /RI_ConstraintTrigger/
        end.each do |dep|
          remove(dep, sql)
        end
      end
      table.indexes.each do |idx|
        # if columns i referenced were removed ...
        if idx.columns.reduce(false) {|acc, col| acc || removed?("TABLE COLUMN #{col} ON #{table.name}") }
          add_plan(idx.gid, :skipped)
        end
        target.dependencies_subgraph_for(idx.gid).order[0..-2].select do |dep|
          dep !~ /RI_ConstraintTrigger/
        end.each do |dep|
          remove(dep, sql)
        end
      end
      table.constraints.each do |ctt|
        remove(ctt.gid, sql)
      end
      table.indexes.each do |idx|
        remove(idx.gid, sql)
      end
    end

    def change(gid, op, sql, &blk)
      return if changed?(gid)

      snode = source.find_by_gid(gid)
      tnode = target.find_by_gid(gid)

      add_plan(gid, :changed, op)
      sql << header("Changing #{gid} (#{op})")
      yield snode, tnode
    end

    def to_sql
      presql = []
      sql = []

      sql << sql_line("BEGIN;")

      puts "Initiating diff"
      # ROLE
      # SCHEMA
      # EXTENSION
      # ENUM
      # AGGREGATE
      # DOMAIN / DOMAIN CONSTRAINT
      # COMPOSITE TYPE
      # SEQUENCE
      # FUNCTION
      # TABLE / TABLE COLUMN / TABLE INDEX / TABLE CONSTRAINT
      # VIEW  / MATERIALIZED VIEW

      common("objects").each{|gid| @common[gid] = true }

      puts "Diffing roles"
      sql << SPACER << "---- ROLES ----" << SPACER
      to_be_added(:roles).each do |gid|
        add(gid, sql)
      end

      to_be_removed(:roles).each do |gid|
        remove(gid, sql)
      end

      puts "Diffing schemas"
      sql << SPACER << "---- SCHEMAS ----" << SPACER
      to_be_added(:schemas).each do |gid|
        add(gid, sql)
      end

      to_be_removed(:schemas).each do |gid|
        remove(schema)
      end

      puts "Diffing extensions"
      sql << SPACER << "---- EXTENSIONS ----" << SPACER
      to_be_added(:extensions).each do |gid|
        add(gid, sql)
      end

      to_be_removed(:extensions).each do |gid|
        remove(gid, sql)
      end

      ## from now on there's dependency hell...
      puts "Diffing enums"
      sql << SPACER << "---- ENUMS ----" << SPACER
      to_be_added(:enums).each do |gid|
        add(gid, sql)
      end

      to_be_removed(:enums).each do |gid|
        remove(gid, sql)
      end

      # ALTER TYPE cannot run inside a transaction block
      to_be_changed(:enums).each do |gid|
        senum = source.find_by_gid(gid)
        tenum = target.find_by_gid(gid)

        senum.changeset(tenum).each_pair do |k, _|
          case k
          when :elements
            presql << senum.change(tenum)
          end
          add_plan(senum.gid, :changed, :change)
          add_plan(tenum.gid, :changed, :change)
        end
      end

      puts "Diffing aggregates"
      sql << SPACER << "---- AGGREGATES ----" << SPACER
      to_be_added(:aggregates).each do |gid|
        add(gid, sql)
      end

      to_be_removed(:aggregates).each do |gid|
        remove(gid, sql)
      end

      to_be_changed(:aggregates).select do |gid|
        saggregate = source.find_by_gid(gid)
        taggregate = target.find_by_gid(gid)
        saggregate.changeset(taggregate).each_pair do |k, _|
          case k
          when :definition
            pending(gid, :change, sql)
          end
          add_plan(saggregate.gid, :changed, :change)
          add_plan(taggregate.gid, :changed, :change)
        end
      end

      puts "Diffing other types"
      sql << SPACER << "---- TYPES ----" << SPACER
      to_be_added(:types).select do |type|
        add(type, sql)
      end

      to_be_removed(:types).select do |type|
        remove(type, sql)
      end

      to_be_changed(:types).select do |gid|
        stype = source.find_by_gid(gid)
        ttype = target.find_by_gid(gid)
        stype.changeset(ttype).each_pair do |k, _|
          case k
          when :definition
            pending(gid, :change, sql)
          end
          add_plan(stype.gid, :changed, :change)
          add_plan(ttype.gid, :changed, :change)
        end
      end

      puts "Diffing domains"
      sql << SPACER << "---- DOMAINS ----" << SPACER
      to_be_added(:domains).select do |domain|
        add(domain, sql)
        source.find_by_gid(domain).constraints.each {|c| add(c.gid, sql)}
      end

      to_be_removed(:domains).select do |domain|
        target.find_by_gid(domain).constraints.each {|c| remove(c.gid, sql)}
        remove(domain, sql)
      end

      to_be_changed(:domains).select do |gid|
        sdomain = source.find_by_gid(gid)
        tdomain = target.find_by_gid(gid)
        sdomain.changeset(tdomain).each_pair do |k, _|
          case k
          when :name
            change(gid, :rename, sql) do |_, tnode|
              sql << sql_line(tdomain.rename(sdomain.name))
            end
          when :schema
            change(gid, :set_schema, sql) do |_, tnode|
              sql << sql_line(tdomain.set_schema(sdomain.schema))
            end
          end
          add_plan(sdomain.gid, :changed, :change)
          add_plan(tdomain.gid, :changed, :change)
        end
      end

      puts "Diffing sequences"
      sql << SPACER << "---- SEQUENCES ----" << SPACER
      to_be_added(:sequences).select do |sequence|
        add(sequence, sql)
      end

      to_be_removed(:sequences).select do |sequence|
        remove(sequence, sql)
      end

      to_be_changed(:sequences).select do |gid|
        ssequence = source.find_by_gid(gid)
        tsequence = target.find_by_gid(gid)
        ssequence.changeset(tsequence).each_pair do |k, _|
          pending(gid, k, sql)
          add_plan(ssequence.gid, :changed, :change)
          add_plan(tsequence.gid, :changed, :change)
        end
      end

      puts "Diffing tables"
      sql << SPACER << "---- TABLES ----" << SPACER
      to_be_added(:tables).select do |table|
        source.prerequisites_subgraph_for(table).order[0..-2].each do |prerequisite|
          add(prerequisite, sql)
        end
        add(table, sql)
      end

      to_be_removed(:tables).select do |table|
        remove(table, sql)
      end

      to_be_changed(:tables).select do |table|
        stable = source.find_by_gid(table)
        ttable = target.find_by_gid(table)
        changes = stable.changeset(ttable)

        changes.each_pair do |gid, options|
          case options[:op]
          when :add
            add(gid, sql)
          when :remove
            node = target.find_by_gid(gid)
            views = []
            target.dependencies_subgraph_for(gid).order.each do |dgid|
              if dgid =~ /MATERIALIZED VIEW/
                views << dgid
                remove(dgid, sql)
              end
              if dgid =~ /TRIGGER/
                remove(dgid, sql)
              end
            end
            remove(gid, sql)
            views.each{|v| add(v, sql)}
          when :rename
            change(gid, options[:op], sql) do |_, tnode|
              snode = source.find_by_gid(options[:source])
              sql << sql_line(tnode.rename(snode.name))
              add_plan(snode.gid, :changed, options[:op])
            end
          else
            pending(gid, options[:op], sql)
          end
        end
      end

      puts "Diffing functions"
      sql << SPACER << "---- FUNCTIONS ----" << SPACER
      to_be_added(:functions).select do |function|
        add(function, sql)
      end

      to_be_removed(:functions).select do |function|
        remove(function, sql)
      end

      to_be_changed(:functions).select do |function|
        pending(function, :change, sql)
      end

      puts "Diffing views"
      sql << SPACER << "---- VIEWS ----" << SPACER
      to_be_added(:views).select do |view|
        sview = source.find_by_gid(view)
        if sview
          something_changed = sview.dependencies.i_depend_on.referenced.reduce(false) do |changed, ref|
            changed || @plan[ref.gid][:changed] || @plan[ref.gid][:removed]
          end

          if something_changed
            sql << %Q{-- #{view} cannot be inserted because some of its dependencies changed in the current transaction, skipping ...}
            add_plan(view, :skipped)
          else
            add(view, sql)
          end
        end
      end

      to_be_removed(:views).select do |view|
        remove(view, sql)
      end

      to_be_changed(:views).select do |view|
        pending(view, :change, sql)
      end

      puts "Diffing triggers"
      to_be_removed(:triggers).select do |trigger|
        remove(trigger, sql)
      end

      to_be_added(:triggers).select do |trigger|
        add(trigger, sql)
      end

      if PgDiff.args.migration
        table, column = PgDiff.args.migration.split(".")

        sql << sql_line(%Q{INSERT INTO #{table} (#{column}) VALUES ('#{PgDiff.args.timestamp}');})
      end

      sql << SPACER << sql_line("COMMIT;")

      if presql.length > 0
        presql.join("\n") + SPACER + sql.join("\n")
      else
        sql.join("\n")
      end
    end
  end
end