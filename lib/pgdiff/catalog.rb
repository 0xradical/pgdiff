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
      schema, table = table_name =~ /\./ ? table_name.split(".") : ["public", table_name]

      exec(%Q{
        SELECT relhasoids
				FROM pg_class c
				INNER JOIN pg_namespace n ON n."oid" = c.relnamespace AND n.nspname = '#{schema}'
				WHERE c.relname = '#{table}'
      })
    end

    private

    def exec(query)
      @connection.exec(query).entries
    end
  end
end