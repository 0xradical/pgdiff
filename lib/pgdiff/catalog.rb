module PgDiff
  class Catalog
    def initialize(connection)
      @connection = connection
    end

    def schemas
      return @schemas if @schemas

      @schemas = exec(%Q{
        SELECT nspname FROM pg_namespace
					WHERE nspname NOT IN ('pg_catalog','information_schema')
					AND nspname NOT LIKE 'pg_toast%'
					AND nspname NOT LIKE 'pg_temp%';
      })
    end

    def tables(schemas = self.schemas.map{|row| row["nspname"] })
      return @tables if @tables

      @tables = exec(%Q{
        SELECT schemaname, tablename, tableowner
				FROM pg_tables t
				INNER JOIN pg_namespace n ON t.schemaname = n.nspname
                INNER JOIN pg_class c ON t.tablename = c.relname AND c.relnamespace = n."oid"
                WHERE t.schemaname IN ('#{schemas.join("','")}')
                AND c.oid NOT IN (
                    SELECT d.objid
                    FROM pg_depend d
                    WHERE d.deptype = 'e'
                );
      })
    end

    def table_options(table_name)
      schema, table = schema_and_table(table_name)

      exec(%Q{
        SELECT relhasoids
				FROM pg_class c
				INNER JOIN pg_namespace n ON n."oid" = c.relnamespace AND n.nspname = '#{schema}'
				WHERE c.relname = '#{table}'
      })
    end

    def table_columns(table_name)
      schema, table = schema_and_table(table_name)

      exec(%Q{SELECT a.attname, a.attnotnull, t.typname, t.oid as typeid, t.typcategory, pg_get_expr(ad.adbin ,ad.adrelid ) as adsrc, a.attidentity,
                  CASE
                      WHEN t.typname = 'numeric' AND a.atttypmod > 0 THEN (a.atttypmod-4) >> 16
                      WHEN (t.typname = 'bpchar' or t.typname = 'varchar') AND a.atttypmod > 0 THEN a.atttypmod-4
                      ELSE null
                  END AS precision,
                  CASE
                      WHEN t.typname = 'numeric' AND a.atttypmod > 0 THEN (a.atttypmod-4) & 65535
                      ELSE null
                  END AS scale
                  FROM pg_attribute a
                  INNER JOIN pg_type t ON t.oid = a.atttypid
          LEFT JOIN pg_attrdef ad on ad.adrelid = a.attrelid AND a.attnum = ad.adnum
          INNER JOIN pg_namespace n ON n.nspname = '#{schema}'
          INNER JOIN pg_class c ON c.relname = '#{table}' AND c.relnamespace = n."oid"
                  WHERE attrelid = c."oid" AND attnum > 0 AND attisdropped = false
          ORDER BY a.attnum ASC
      });
    end

    private

    def exec(query)
      @connection.exec(query).entries
    end

    def schema_and_table(table)
      table =~ /\./ ? table.split(".") : ["public", table]
    end
  end
end