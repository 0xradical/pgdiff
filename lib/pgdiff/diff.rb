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
      @plan    = Hash.new{|h,k| h[k] = {:added=>false, :removed=>false, :changed=>false, :skipped => false, :position=>0}}
      @counter = 0
    end

    def add_plan(gid, operation)
      @plan[gid][operation] = true
      @plan[gid][:position] = (@counter += 1)
    end

    def added?(gid)
      @plan[gid][:added]
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

    def process(node)
    end

    def sql_line(line)
      line << SPACER
    end

    def add(gid, sql)
      return if added?(gid) || common?(gid)

      node = source.find_by_gid(gid)
      if !node
        sql << header("Skipping #{gid}")
        add_plan(gid, :skipped)
        return
      end

      add_plan(gid, :added)

      sql << header("Adding #{gid}")
      sql << sql_line(node.add)

      node.dependencies.others_depend_on_me.by_type("oncreate").objects.each do |object|
        add(object.gid, sql)
      end
    end

    def remove(gid, sql)
      return if removed?(gid) || common?(gid)

      node = target.find_by_gid(gid)
      if !node
        sql << header("Skipping #{gid}")
        add_plan(gid, :skipped)
        return
      end

      add_plan(gid, :removed)
      node.dependencies.others_depend_on_me.by_type("internal").objects.each do |object|
        remove(object.gid, sql)
      end
      sql << header("Removing #{gid}")
      sql << sql_line(node.remove)
    end

    def to_sql
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
      to_be_added(:roles).each do |gid|
        add(gid, sql)
      end

      to_be_removed(:roles).each do |gid|
        remove(gid, sql)
      end

      puts "Diffing schemas"
      to_be_added(:schemas).each do |gid|
        add(gid, sql)
      end

      to_be_removed(:schemas).each do |gid|
        remove(schema)
      end

      to_be_changed(:schemas).each do |gid|
        # sschema = source.find_by_gid(gid)
        # tschema = target.find_by_gid(gid)
        # if sschema.to_s != tschema
        #   sql << header("Changing schema #{gid}: not implemented yet")
        #   @changed[gid] = true
        # end
      end

      puts "Diffing extensions"
      to_be_added(:extensions).each do |gid|
        add(gid, sql)
      end

      to_be_removed(:extensions).each do |gid|
        remove(gid, sql)
      end

      to_be_changed(:extensions).each do |gid|
        # sextension = source.find_by_gid(gid)
        # textension = target.find_by_gid(gid)
        # if sextension.to_s != textension
        #   sql << header("Changing extension #{gid}: not implemented yet")
        #   @changed[gid] = true
        # end
      end

      ## from now on there's dependency hell...
      puts "Diffing enums"
      to_be_added(:enums).each do |gid|
        add(gid, sql)
      end

      to_be_removed(:enums).each do |gid|
        remove(gid, sql)
      end

      # to_be_changed(:enums).each do |gid|
      #   senum = source.find_by_gid(gid)
      #   tenum = target.find_by_gid(gid)
      #   if senum.to_s != tenum
      #     sql << header("Changing enum #{gid}: not implemented yet")
      #     @changed[gid] = true
      #   end
      # end

      puts "Diffing aggregates"
      to_be_added(:aggregates).each do |gid|
        add(gid, sql)
      end

      to_be_removed(:aggregates).each do |gid|
        remove(gid, sql)
      end

      # to_be_changed(:aggregates).each do |gid|
      #   saggregate = source.find_by_gid(gid)
      #   taggregate = target.find_by_gid(gid)
      #   if saggregate.to_s != taggregate
      #     sql << header("Changing aggregate #{gid}: not implemented yet")
      #     @changed[gid] = true
      #   end
      # end

      puts "Diffing other types"
      to_be_added(:types).select do |type|
        add(type, sql)
      end

      to_be_removed(:types).select do |type|
        remove(type, sql)
      end
      # to_be_added(:types).select do |type|
      #   type !~ /\[\]\Z/
      # end.each do |gid|
      #   pretypes = source.subgraph_for(gid).reverse_order.select do |ptype|
      #     !@added[ptype] && !@common[ptype]
      #   end

      #   pretypes.each do |pgid|
      #     sql << header("Adding type #{pgid}")
      #     sql << sql_line(source.find_by_gid(pgid).add)
      #     @added[pgid] = true
      #   end
      # end

      # to_be_removed(:types).select do |type|
      #   ttype = target.find_by_gid(type)
      #   ttype.category != "A"
      # end.each do |gid|
      #   sql << header("Removing type #{gid}")

      #   deps = target.find_by_gid(gid).dependencies.others_depend_on_me.internal.objects.select do |object|
      #     object.gid !~ /#{gid}\[\]/
      #   end
      #   if deps.count > 0
      #     sql << sql_line(header("The following objects depend on this type: "))
      #     deps.each do |object|
      #       sql << sql_line(header("  * #{object.gid}"))
      #     end
      #     sql << sql_line(header("Skipping #{gid} removal"))
      #   else
      #     sql << sql_line(target.find_by_gid(gid).remove)
      #     @removed[gid] = true
      #     deps.each {|dep| @removed[dep] = true }
      #   end
      # end

      # to_be_changed(:types).select do |type|
      #   type !~ /\[\]\Z/ && !@changed[type]
      # end.each do |gid|
      #   stype = source.find_by_gid(gid)
      #   ttype = target.find_by_gid(gid)
      #   if stype.to_s != ttype
      #     sql << header("Changing type #{gid}: not implemented yet")
      #     @changed[gid] = true
      #   end
      # end


      puts "Diffing domains"
      to_be_added(:domains).select do |domain|
        add(domain, sql)
        source.find_by_gid(domain).constraints.each {|c| add(c.gid, sql)}
      end

      to_be_removed(:domains).select do |domain|
        target.find_by_gid(domain).constraints.each {|c| remove(c.gid, sql)}
        remove(domain, sql)
      end

      # to_be_added(:domains).select do |domain|
      #   domain !~ /\[\]\Z/
      # end.each do |gid|
      #   predomains = source.subgraph_for(gid).reverse_order.select do |pdomain|
      #     !@added[pdomain] && !@common[pdomain]
      #   end

      #   predomains.each do |pgid|
      #     sql << header("Adding domain #{pgid}")
      #     sql << sql_line(source.find_by_gid(pgid).add)

      #     @added[pgid] = true
      #   end
      # end

      # to_be_removed(:domains).select do |domain|
      #   tdomain = target.find_by_gid(domain)
      #   tdomain.category != "A"
      # end.each do |gid|
      #   sql << header("Removing domain #{gid}")

      #   deps = target.find_by_gid(gid).dependencies.others_depend_on_me.internal.objects.select do |object|
      #     object.gid !~ /#{gid}\[\]/
      #   end
      #   if deps.count > 0
      #     sql << sql_line(header("The following objects depend on this domain: "))
      #     deps.each do |object|
      #       sql << sql_line(header("  * #{object.gid}"))
      #     end
      #     sql << sql_line(header("Skipping #{gid} removal"))
      #   else
      #     sql << sql_line(target.find_by_gid(gid).remove)
      #     @removed[gid] = true
      #     deps.each {|dep| @removed[dep] = true }
      #   end
      # end

      # to_be_changed(:domains).select do |domain|
      #   domain !~ /\[\]\Z/ && !@changed[domain]
      # end.each do |gid|
      #   sdomain = source.find_by_gid(gid)
      #   tdomain = target.find_by_gid(gid)
      #   if sdomain.to_s != tdomain
      #     sql << header("Changing domain #{gid}: not implemented yet")
      #     @changed[gid] = true
      #   end
      # end


      puts "Diffing sequences"
      to_be_added(:sequences).select do |sequence|
        add(sequence, sql)
      end

      to_be_removed(:sequences).select do |sequence|
        remove(sequence, sql)
      end

      puts "Diffing tables"
      to_be_added(:tables).select do |table|
        source.prerequisites_subgraph_for(table).order[0..-2].each do |prerequisite|
          add(prerequisite, sql)
        end
        add(table, sql)
      end

      to_be_removed(:tables).select do |table|
        remove(table, sql)
      end

      puts "Diffing functions"
      to_be_added(:functions).select do |function|
        add(function, sql)
      end

      to_be_removed(:functions).select do |function|
        remove(function, sql)
      end

      if PgDiff.args.migration
        table, column = PgDiff.args.migration.split(".")

        sql << sql_line(%Q{INSERT INTO #{table} (#{column}) VALUES ('#{PgDiff.args.timestamp}');})
      end

      sql << SPACER << sql_line("COMMIT;")

      sql.join("\n")
    end
  end
end