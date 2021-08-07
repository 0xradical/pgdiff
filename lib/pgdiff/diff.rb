module PgDiff
  class Diff
    SPACER = "\n"

    attr_reader :source, :target

    def initialize(source, target)
      @source  = source
      @target  = target
      @added   = Hash.new
      @removed = Hash.new
      @changed = Hash.new
    end

    def to_be_added(klass)
      Set.new(source.public_send(klass).values.map(&:gid)) - Set.new(target.public_send(klass).values.map(&:gid))
    end

    def to_be_removed(klass)
      Set.new(target.public_send(klass).values.map(&:gid)) - Set.new(source.public_send(klass).values.map(&:gid))
    end

    def common(klass)
      Set.new(source.public_send(klass).values.map(&:gid)) & Set.new(target.public_send(klass).values.map(&:gid))
    end

    def header(text)
      sql_line(%Q{-- #{text}})
    end

    def sql_line(line)
      line << SPACER
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
      # FUNCTION

      puts "Diffing roles"
      to_be_added(:roles).each do |gid|
        sql << header("Adding role #{gid}")
        sql << sql_line(source.find_by_gid(gid).add)
        @added[gid] = true
      end

      to_be_removed(:roles).each do |gid|
        sql << header("Removing role #{gid}")

        if target.find_by_gid(gid).dependencies.others_depend_on_me.internal.objects.count > 0
          sql << sql_line(header("The following objects depend on this role: "))
          target.find_by_gid(gid).dependencies.others_depend_on_me.internal.objects.each do |object|
            sql << sql_line(header("  * #{object.gid}"))
          end
          sql << sql_line(header("Skipping #{gid} removal"))
        else
          sql << header("Removing role #{gid}")
          sql << sql_line(target.find_by_gid(gid).remove)
          @removed[gid] = true
        end
      end

      puts "Diffing schemas"
      to_be_added(:schemas).each do |gid|
        sql << header("Adding schema #{gid}")
        sql << sql_line(source.find_by_gid(gid).add)
        @added[gid] = true
      end

      to_be_removed(:schemas).each do |gid|
        sql << header("Removing schema #{gid}")

        if target.find_by_gid(gid).dependencies.others_depend_on_me.internal.objects.count > 0
          sql << sql_line(header("The following objects depend on this schema: "))
          target.find_by_gid(gid).dependencies.others_depend_on_me.internal.objects.each do |object|
            sql << sql_line(header("  * #{object.gid}"))
          end
          sql << sql_line(header("Skipping #{gid} removal"))
        else
          sql << sql_line(target.find_by_gid(gid).remove)
          @removed[gid] = true
        end
      end

      common(:schemas).each do |gid|
        sschema = source.find_by_gid(gid)
        tschema = target.find_by_gid(gid)
        if sschema.to_s != tschema
          sql << header("Changing schema #{gid}: not implemented yet")
          @changed[gid] = true
        end
      end

      puts "Diffing extensions"
      to_be_added(:extensions).each do |gid|
        sql << header("Adding extension #{gid}")
        sql << sql_line(source.find_by_gid(gid).add)
        @added[gid] = true
      end

      to_be_removed(:extensions).each do |gid|
        sql << header("Removing extension #{gid}")

        if target.find_by_gid(gid).dependencies.others_depend_on_me.internal.objects.count > 0
          sql << sql_line(header("The following objects depend on this extension: "))
          target.find_by_gid(gid).dependencies.others_depend_on_me.internal.objects.each do |object|
            sql << sql_line(header("  * #{object.gid}"))
          end
          sql << sql_line(header("Skipping #{gid} removal"))
        else
          sql << sql_line(target.find_by_gid(gid).remove)
          @removed[gid] = true
        end
      end

      common(:extensions).each do |gid|
        sextension = source.find_by_gid(gid)
        textension = target.find_by_gid(gid)
        if sextension.to_s != textension
          sql << header("Changing extension #{gid}: not implemented yet")
          @changed[gid] = true
        end
      end

      puts "Diffing enums"
      to_be_added(:enums).each do |gid|
        sql << header("Adding enum #{gid}")
        sql << sql_line(source.find_by_gid(gid).add)
        @added[gid] = true
      end

      to_be_removed(:enums).each do |gid|
        sql << header("Removing enum #{gid}")

        # array types are automatic despite being marked as internal...
        deps = target.find_by_gid(gid).dependencies.others_depend_on_me.internal.objects.select do |object|
          object.gid !~ /#{gid}\[\]/
        end

        if deps.count > 0
          sql << sql_line(header("The following objects depend on this enum: "))
          deps.each do |object|
            sql << sql_line(header("  * #{object.gid}"))
          end
          sql << sql_line(header("Skipping #{gid} removal"))
        else
          sql << sql_line(target.find_by_gid(gid).remove)
          @removed[gid] = true
        end
      end

      common(:enums).each do |gid|
        senum = source.find_by_gid(gid)
        tenum = target.find_by_gid(gid)
        if senum.to_s != tenum
          sql << header("Changing enum #{gid}: not implemented yet")
          @changed[gid] = true
        end
      end

      puts "Diffing aggregates"
      to_be_added(:aggregates).each do |gid|
        sql << header("Adding aggregate #{gid}")
        sql << sql_line(source.find_by_gid(gid).add)
        @added[gid] = true
      end

      to_be_removed(:aggregates).each do |gid|
        sql << header("Removing aggregate #{gid}")

        if target.find_by_gid(gid).dependencies.others_depend_on_me.internal.objects.count > 0
          sql << sql_line(header("The following objects depend on this aggregate: "))
          target.find_by_gid(gid).dependencies.others_depend_on_me.internal.objects.each do |object|
            sql << sql_line(header("  * #{object.gid}"))
          end
          sql << sql_line(header("Skipping #{gid} removal"))
        else
          sql << sql_line(target.find_by_gid(gid).remove)
          @removed[gid] = true
        end
      end

      common(:aggregates).each do |gid|
        saggregate = source.find_by_gid(gid)
        taggregate = target.find_by_gid(gid)
        if saggregate.to_s != taggregate
          sql << header("Changing aggregate #{gid}: not implemented yet")
          @changed[gid] = true
        end
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