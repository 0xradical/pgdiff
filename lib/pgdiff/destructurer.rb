require "pry"
require "fileutils"

module PgDiff
  class Destructurer
    attr_reader :world

    def initialize(world)
      @world = world
    end

    def destructure(folder)
      FileUtils.mkdir_p(File.join(folder))
      FileUtils.rm_rf(File.join(folder, "**"))

      # schemas
      File.open(File.join(folder, "schemas.sql"), "w") do |f|
        world.schemas.sort_by{|k,_| k}.each do |gid, schema|
          f.write(%Q{#{schema.ddl}\n}) if schema.ddl.length > 0
        end
      end

      # roles
      File.open(File.join(folder, "roles.sql"), "w") do |f|
        world.roles.sort_by{|k,_| k}.each do |gid, role|
          f.write(%Q{#{role.ddl}\n}) if role.ddl.length > 0
        end
      end

      # extensions
      File.open(File.join(folder, "extensions.sql"), "w") do |f|
        world.extensions.sort_by{|k,v| v.data['name'] }.each do |gid, extension|
          f.write(%Q{#{extension.ddl}\n}) if extension.ddl.length > 0
        end
      end

      # enums
      FileUtils.mkdir_p(File.join(folder,"enums"))

      enums_by_schema = world.enums.group_by{|k,v| v.schema }
      enums_by_schema.each do |schema, enums|
        FileUtils.mkdir_p(File.join(folder,"enums", schema))

        enums.sort_by{|k,_| k}.each do |gid, enum|
          File.open(File.join(folder, "enums", schema, "#{enum.data['name']}.sql"), "w") do |f|
            f.write(%Q{#{enum.ddl}\n}) if enum.ddl.length > 0
          end
        end
      end

      # aggregates
      FileUtils.mkdir_p(File.join(folder,"aggregates"))

      aggregates_by_schema = world.aggregates.group_by{|k,v| v.nspname }
      aggregates_by_schema.each do |schema, aggregates|
        FileUtils.mkdir_p(File.join(folder,"aggregates", schema))

        aggregates.sort_by{|k,_| k}.each do |gid, aggregate|
          File.open(File.join(folder, "aggregates", schema, "#{aggregate.proname}.sql"), "w") do |f|
            f.write(%Q{#{aggregate.ddl}\n}) if aggregate.ddl.length > 0
          end
        end
      end

      # domains
      FileUtils.mkdir_p(File.join(folder,"domains"))

      domains_by_schema = world.domains.select{|k,v| !v.system? }.group_by{|k,v| v.schema }
      domains_by_schema.each do |schema, domains|
        FileUtils.mkdir_p(File.join(folder,"domains", schema))

        domains.sort_by{|k,_| k}.each do |gid, domain|
          FileUtils.mkdir_p(File.join(folder,"domains", schema, domain.data['name']))

          if domain.ddl.length > 0
            File.open(File.join(folder, "domains", schema, domain.data['name'], "definition.sql"), "w") do |f|
              f.write(%Q{#{domain.ddl}\n})
            end
          end

          File.open(File.join(folder,"domains", schema, domain.data['name'], "constraints.sql"), "w") do |cf|
            domain.constraints.sort_by{|ctt| ctt.name }.each do |domain_constraint|
              cf.write(%Q{#{domain_constraint.ddl}\n}) if domain_constraint.ddl.length > 0
            end
          end
        end
      end

      # composite types
      FileUtils.mkdir_p(File.join(folder,"composite"))

      types_by_schema = world.types.select{|k,v| v.category == "C"}.group_by{|k,v| v.schema }
      types_by_schema.each do |schema, types|
        FileUtils.mkdir_p(File.join(folder,"composite", schema))

        types.sort_by{|k,_| k}.each do |gid, type|
          next unless type.ddl.length > 0
          File.open(File.join(folder, "composite", schema, "#{type.data['internal_name']}.sql"), "w") do |f|
            f.write(%Q{#{type.ddl}\n})
          end
        end
      end

      # tables
      FileUtils.mkdir_p(File.join(folder,"tables"))

      tables_by_schema = world.tables.group_by{|k,v| v.schemaname }
      tables_by_schema.each do |schema, tables|
        FileUtils.mkdir_p(File.join(folder,"tables", schema))

        tables.sort_by{|k, _| k}.each do |gid, table|
          FileUtils.mkdir_p(File.join(folder,"tables", schema, table.tablename))

          if table.ddl.length > 0
            File.open(File.join(folder,"tables", schema, table.tablename, "definition.sql"), "w") do |f|
              f.write(%Q{#{table.ddl}\n})
            end
          end

          File.open(File.join(folder,"tables", schema, table.tablename, "indexes.sql"), "w") do |f|
            table.indexes.sort_by{|idx| idx.name }.each do |idx|
              next unless idx.ddl.length > 0
              f.write(%Q{#{idx.ddl}\n})
            end
          end

          File.open(File.join(folder,"tables", schema, table.tablename, "privileges.sql"), "w") do |f|
            f.write(%Q{#{table.privilege.ddl}\n})
          end

          File.open(File.join(folder,"tables", schema, table.tablename, "triggers.sql"), "w") do |f|
            table.triggers.sort_by{|tg| tg.name }.each do |tg|
              next unless tg.ddl.length > 0
              f.write(%Q{#{tg.ddl}\n})
            end
          end
        end
      end

      # views / materialized views
      FileUtils.mkdir_p(File.join(folder,"views"))

      views_by_schema = world.views.group_by{|k,v| v.schemaname }
      views_by_schema.each do |schema, views|
        FileUtils.mkdir_p(File.join(folder,"views", schema))

        views.sort_by{|k, _| k}.each do |gid, view|
          FileUtils.mkdir_p(File.join(folder,"views", schema, view.viewname))

          if view.ddl.length > 0
            File.open(File.join(folder,"views", schema, view.viewname, "definition.sql"), "w") do |f|
              f.write(%Q{#{view.ddl}\n})
            end
          end

          File.open(File.join(folder,"views", schema, view.viewname, "privileges.sql"), "w") do |f|
            f.write(%Q{#{view.privilege.ddl}\n})
          end

          File.open(File.join(folder,"views", schema, view.viewname, "triggers.sql"), "w") do |f|
            view.triggers.sort_by{|tg| tg.name }.each do |tg|
              next unless tg.ddl.length > 0
              f.write(%Q{#{tg.ddl}\n})
            end
          end
        end
      end

      # functions
      FileUtils.mkdir_p(File.join(folder,"functions"))
      functions_by_schema = world.functions.group_by{|k,v| v.nspname }
      functions_by_schema.each do |schema, functions|
        FileUtils.mkdir_p(File.join(folder,"functions", schema))

        functions.sort_by{|k, _| k}.each do |gid, function|
          next unless function.ddl.length > 0
          File.open(File.join(folder, "functions", schema, "#{function.proname}.sql"), "w") do |f|
            f.write(%Q{#{function.ddl}\n})
          end
        end
      end

      if PgDiff.args.user_id && PgDiff.args.group_id
        FileUtils.chown_R PgDiff.args.user_id, PgDiff.args.group_id, folder
      end
    end
  end
end