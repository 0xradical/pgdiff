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
				WHERE c.relname = '#{table}';
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
          ORDER BY a.attnum ASC;
      });
    end

    def table_constraints(table_name)
      schema, table = schema_and_table(table_name)

      exec(%Q{
        SELECT conname, contype, pg_get_constraintdef(c.oid) as definition
				FROM pg_constraint c
				INNER JOIN pg_namespace n ON n.nspname = '#{schema}'
                INNER JOIN pg_class cl ON cl.relname ='#{table}' AND cl.relnamespace = n.oid
				WHERE c.conrelid = cl.oid;
      })
    end

    def table_indexes(table_name)
      schema, table = schema_and_table(table_name)

      exec(%Q{
        SELECT idx.relname as indexname, pg_get_indexdef(idx.oid) AS indexdef
        FROM pg_index i
        INNER JOIN pg_class tbl ON tbl.oid = i.indrelid
        INNER JOIN pg_namespace tbln ON tbl.relnamespace = tbln.oid
                INNER JOIN pg_class idx ON idx.oid = i.indexrelid
        WHERE tbln.nspname = '#{schema}' AND tbl.relname='#{table}' AND i.indisprimary = false;
      })
    end

    def table_privileges(table_name)
      schema, table = schema_and_table(table_name)

      exec(%Q{
        SELECT t.schemaname, t.tablename, u.usename,
        HAS_TABLE_PRIVILEGE(u.usename,'"#{schema}"."#{table}"', 'SELECT') as select,
        HAS_TABLE_PRIVILEGE(u.usename,'"#{schema}"."#{table}"', 'INSERT') as insert,
        HAS_TABLE_PRIVILEGE(u.usename,'"#{schema}"."#{table}"', 'UPDATE') as update,
        HAS_TABLE_PRIVILEGE(u.usename,'"#{schema}"."#{table}"', 'DELETE') as delete,
        HAS_TABLE_PRIVILEGE(u.usename,'"#{schema}"."#{table}"', 'TRUNCATE') as truncate,
        HAS_TABLE_PRIVILEGE(u.usename,'"#{schema}"."#{table}"', 'REFERENCES') as references,
        HAS_TABLE_PRIVILEGE(u.usename,'"#{schema}"."#{table}"', 'TRIGGER') as trigger
        FROM pg_tables t, pg_user u
        WHERE t.schemaname = '#{schema}' and t.tablename='#{table}';
      })
    end

    def views(schemas = self.schemas.map{|row| row["nspname"] })
      exec(%Q{
        SELECT schemaname, viewname, viewowner, definition
        FROM pg_views v
        INNER JOIN pg_namespace n ON v.schemaname = n.nspname
        INNER JOIN pg_class c ON v.viewname = c.relname AND c.relnamespace = n."oid"
                WHERE v.schemaname IN ('#{schemas.join("','")}')
                AND c.oid NOT IN (
                    SELECT d.objid
                    FROM pg_depend d
                    WHERE d.deptype = 'e'
        );
      })
    end

    def view_privileges(view_name)
      schema, view = schema_and_table(view_name)

      exec(%Q{
        SELECT v.schemaname, v.viewname, u.usename,
        HAS_TABLE_PRIVILEGE(u.usename,'"#{schema}"."#{view}"', 'SELECT') as select,
        HAS_TABLE_PRIVILEGE(u.usename,'"#{schema}"."#{view}"', 'INSERT') as insert,
        HAS_TABLE_PRIVILEGE(u.usename,'"#{schema}"."#{view}"', 'UPDATE') as update,
        HAS_TABLE_PRIVILEGE(u.usename,'"#{schema}"."#{view}"', 'DELETE') as delete,
        HAS_TABLE_PRIVILEGE(u.usename,'"#{schema}"."#{view}"', 'TRUNCATE') as truncate,
        HAS_TABLE_PRIVILEGE(u.usename,'"#{schema}"."#{view}"', 'REFERENCES') as references,
        HAS_TABLE_PRIVILEGE(u.usename,'"#{schema}"."#{view}"', 'TRIGGER') as trigger
        FROM pg_views v, pg_user u
        WHERE v.schemaname = '#{schema}' and v.viewname='#{view}';
      })
    end

    def materialized_views(schemas = self.schemas.map{|row| row["nspname"] })
      exec(%Q{
        SELECT schemaname, matviewname, matviewowner, definition
        FROM pg_matviews WHERE schemaname IN ('#{schemas.join("','")}');
      })
    end

    def view_dependencies(view_name)
      schema, view = schema_and_table(view_name)

      exec(%Q{
        SELECT
        n.nspname AS schemaname,
        c.relname AS tablename,
        a.attname AS columnname
        FROM pg_rewrite AS r
        INNER JOIN pg_depend AS d ON r.oid=d.objid
        INNER JOIN pg_attribute a ON a.attnum = d.refobjsubid AND a.attrelid = d.refobjid AND a.attisdropped = false
        INNER JOIN pg_class c ON c.oid = d.refobjid
        INNER JOIN pg_namespace n ON n.oid = c.relnamespace
        INNER JOIN pg_namespace vn ON vn.nspname = '#{schema}'
                INNER JOIN pg_class vc ON vc.relname = '#{view}' AND vc.relnamespace = vn."oid"
        WHERE r.ev_class = vc.oid AND d.refobjid <> vc.oid;
      })
    end

    def functions(schemas = self.schemas.map{|row| row["nspname"] })
      exec(%Q{
        SELECT p.proname, n.nspname, pg_get_functiondef(p.oid) as definition, p.proowner::regrole::name as owner, oidvectortypes(proargtypes) as argtypes
        FROM pg_proc p
        INNER JOIN pg_namespace n ON n.oid = p.pronamespace
        WHERE n.nspname IN ('#{schemas.join("','")}') AND p.probin IS NULL AND p.prokind = 'f' AND p."oid" NOT IN (
                    SELECT d.objid
                    FROM pg_depend d
                    WHERE d.deptype = 'e'
                );
      })
    end

    def aggregates(schemas = self.schemas.map{|row| row["nspname"] })
      exec(%Q{
        SELECT p.proname, n.nspname, p.proowner::regrole::name as owner, oidvectortypes(proargtypes) as argtypes,
        format('%s', array_to_string(
          ARRAY[
            format(E'\\tSFUNC = %s', a.aggtransfn::text)
            , format(E'\\tSTYPE = %s', format_type(a.aggtranstype, NULL))
            , format(E'\\tSSPACE = %s',a.aggtransspace)
            , CASE a.aggfinalfn WHEN '-'::regproc THEN NULL ELSE format(E'\\tFINALFUNC = %s',a.aggfinalfn::text) END
            , CASE WHEN a.aggfinalfn != '-'::regproc AND a.aggfinalextra = true THEN format(E'\\tFINALFUNC_EXTRA') ELSE NULL END
            , CASE WHEN a.aggfinalfn != '-'::regproc THEN format(E'\\tFINALFUNC_MODIFY = %s',
              CASE
                 WHEN a.aggfinalmodify = 'r' THEN 'READ_ONLY'
                 WHEN a.aggfinalmodify = 's' THEN 'SHAREABLE'
                 WHEN a.aggfinalmodify = 'w' THEN 'READ_WRITE'
              END
            ) ELSE NULL END
            , CASE WHEN a.agginitval IS NULL THEN NULL ELSE format(E'\\tINITCOND = %s', a.agginitval) END
            , format(E'\\tPARALLEL = %s',
              CASE
                WHEN p.proparallel = 'u' THEN 'UNSAFE'
                WHEN p.proparallel = 's' THEN 'SAFE'
                WHEN p.proparallel = 'r' THEN 'RESTRICTED'
              END
            )
            , CASE a.aggcombinefn WHEN '-'::regproc THEN NULL ELSE format(E'\\tCOMBINEFUNC = %s',a.aggcombinefn::text) END
            , CASE a.aggserialfn WHEN '-'::regproc THEN NULL ELSE format(E'\\tSERIALFUNC = %s',a.aggserialfn::text) END
            , CASE a.aggdeserialfn WHEN '-'::regproc THEN NULL ELSE format(E'\\tDESERIALFUNC = %s',a.aggdeserialfn::text) END
            , CASE a.aggmtransfn WHEN '-'::regproc THEN NULL ELSE format(E'\\tMSFUNC = %s',a.aggmtransfn::text) END
            , case a.aggmtranstype WHEN '-'::regtype THEN NULL ELSE format(E'\\tMSTYPE = %s', format_type(a.aggmtranstype, NULL)) END
            , case WHEN a.aggmfinalfn != '-'::regproc THEN format(E'\\tMSSPACE = %s',a.aggmtransspace) ELSE NULL END
            , CASE a.aggminvtransfn WHEN '-'::regproc THEN NULL ELSE format(E'\\tMINVFUNC = %s',a.aggminvtransfn::text) END
            , CASE a.aggmfinalfn WHEN '-'::regproc THEN NULL ELSE format(E'\\tMFINALFUNC = %s',a.aggmfinalfn::text) END
            , CASE WHEN a.aggmfinalfn != '-'::regproc and a.aggmfinalextra = true THEN format(E'\\tMFINALFUNC_EXTRA') ELSE NULL END
            , CASE WHEN a.aggmfinalfn != '-'::regproc THEN format(E'\\tMFINALFUNC_MODIFY  = %s',
              CASE
                WHEN a.aggmfinalmodify = 'r' THEN 'READ_ONLY'
                WHEN a.aggmfinalmodify = 's' THEN 'SHAREABLE'
                WHEN a.aggmfinalmodify = 'w' THEN 'READ_WRITE'
              END
             ) ELSE NULL END
            , CASE WHEN a.aggminitval IS NULL THEN NULL ELSE format(E'\\tMINITCOND = %s', a.aggminitval) END
            , CASE a.aggsortop WHEN 0 THEN NULL ELSE format(E'\\tSORTOP = %s', o.oprname) END
          ]
          , E',\\n'
          )
        ) as definition
                FROM pg_proc p
        INNER JOIN pg_namespace n ON n.oid = p.pronamespace
        INNER JOIN pg_aggregate a on p.oid = a.aggfnoid
        LEFT JOIN pg_operator o ON o.oid = a.aggsortop
        WHERE n.nspname IN ('#{schemas.join("','")}')
        AND a.aggkind = 'n'
        AND p.prokind = 'a'
        AND p."oid" NOT IN (
                    SELECT d.objid
                    FROM pg_depend d
                    WHERE d.deptype = 'e'
                );
      })
    end

    def function_privileges(function_name, arg_types = "")
      schema, function = schema_and_table(function_name)

      exec(%Q{
        SELECT n.nspname as pronamespace, p.proname, u.usename,
        HAS_FUNCTION_PRIVILEGE(u.usename,'"#{schema}"."#{function}"(#{arg_types})','EXECUTE') as execute
        FROM pg_proc p, pg_user u
        INNER JOIN pg_namespace n ON n.nspname = '#{schema}'
        WHERE p.proname='#{function}' AND p.pronamespace = n.oid;
      })
    end

    def sequences(schemas = self.schemas.map{|row| row["nspname"] })
      exec(%Q{
        SELECT seq_nspname, seq_name, owner, ownedby_table, ownedby_column,
               p.start_value, p.minimum_value, p.maximum_value, p.increment,
               p.cycle_option, p.cache_size
                    FROM (
                        SELECT
                            c.oid, ns.nspname AS seq_nspname, c.relname AS seq_name, r.rolname as owner, sc.relname AS ownedby_table, a.attname AS ownedby_column
                        FROM pg_class c
                        INNER JOIN pg_namespace ns ON ns.oid = c.relnamespace
                        INNER JOIN pg_roles r ON r.oid = c.relowner
                        INNER JOIN pg_depend d ON d.objid = c.oid AND d.refobjsubid > 0 AND d.deptype ='a'
              INNER JOIN pg_attribute a ON a.attrelid = d.refobjid AND a.attnum = d.refobjsubid
              INNER JOIN pg_class sc ON sc."oid" = d.refobjid
                        WHERE c.relkind = 'S' AND ns.nspname IN ('#{schemas.join("','")}')
                        AND a.attidentity = ''
                    ) s, LATERAL pg_sequence_parameters(s.oid) p;
      })
    end

    def sequence_privileges(sequence_name)
      schema, sequence = schema_and_table(sequence_name)

      exec(%Q{
        SELECT s.sequence_schema, s.sequence_name, u.usename, NULL AS cache_value,
                    HAS_SEQUENCE_PRIVILEGE(u.usename,'"#{schema}"."#{sequence}"', 'SELECT') as select,
                    HAS_SEQUENCE_PRIVILEGE(u.usename,'"#{schema}"."#{sequence}"', 'USAGE') as usage,
                    HAS_SEQUENCE_PRIVILEGE(u.usename,'"#{schema}"."#{sequence}"', 'UPDATE') as update
                    FROM information_schema.sequences s, pg_user u
                    WHERE s.sequence_schema = '#{schema}' and s.sequence_name='#{sequence}';
      })
    end

    def enums(schemas = self.schemas.map{|row| row["nspname"] })
      exec(%Q{
        WITH extension_oids AS (
          SELECT
              objid
          FROM
              pg_depend d
          WHERE
              d.refclassid = 'pg_extension'::regclass AND
              d.classid = 'pg_type'::regclass
        )
        SELECT
          n.nspname AS "schema",
          t.typname AS "name",
          ARRAY(
             SELECT e.enumlabel
              FROM pg_catalog.pg_enum e
              WHERE e.enumtypid = t.oid
              ORDER BY e.enumsortorder
          ) AS elements
        FROM pg_catalog.pg_type t
             LEFT JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
             LEFT OUTER JOIN extension_oids e
               ON t.oid = e.objid
        WHERE
          t.typtype = 'e'
          AND e.objid IS NULL
          AND n.nspname IN ('#{schemas.join("','")}')
        ORDER BY 1, 2;
      })
    end

    def domains(schemas = self.schemas.map{|row| row["nspname"] })
      exec(%Q{
        WITH extension_oids AS (
          SELECT
              objid
          FROM
              pg_depend d
          WHERE
              d.refclassid = 'pg_extension'::regclass AND
              d.classid = 'pg_type'::regclass
        )
        SELECT n.nspname as "schema",
               t.typname as "name",
               pg_catalog.format_type(t.typbasetype, t.typtypmod) as "data_type",
               (CASE t.typtype WHEN 'd' THEN 'domain' WHEN 'e' THEN 'enum' ELSE NULL END) AS "type",
               (SELECT c.collname FROM pg_catalog.pg_collation c, pg_catalog.pg_type bt
                WHERE c.oid = t.typcollation AND bt.oid = t.typbasetype AND t.typcollation <> bt.typcollation) as "collation",
               t.typnotnull as "not_null",
               t.typdefault as "default"
        FROM pg_catalog.pg_type t
             LEFT JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
        WHERE n.nspname IN ('#{schemas.join("','")}')
             AND t.typtype = 'd'
             AND (t.typrelid = 0 OR (SELECT c.relkind = 'c' FROM pg_catalog.pg_class c WHERE c.oid = t.typrelid))
             AND  NOT EXISTS(SELECT 1 FROM pg_catalog.pg_type el WHERE el.oid = t.typelem AND el.typarray = t.oid)
             AND t.oid not in (select * from extension_oids)
        ORDER BY 1, 2;
      })
    end

    def domain_constraints(domain_name)
      schema, domain = schema_and_table(domain_name)

      exec(%Q{
        WITH extension_oids AS (
          SELECT
              objid
          FROM
              pg_depend d
          WHERE
              d.refclassid = 'pg_extension'::regclass AND
              d.classid = 'pg_type'::regclass
        )
        SELECT rr.conname as "constraint_name",
               pg_catalog.pg_get_constraintdef(rr.oid, true) AS "definition"
        FROM pg_catalog.pg_type t
          LEFT JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
          LEFT JOIN pg_catalog.pg_constraint rr on t.oid = rr.contypid
        WHERE n.nspname = '#{schema}' AND t.typname = '#{domain}'
          AND t.typtype = 'd'
          AND (t.typrelid = 0 OR (SELECT c.relkind = 'c' FROM pg_catalog.pg_class c WHERE c.oid = t.typrelid))
          AND  NOT EXISTS(SELECT 1 FROM pg_catalog.pg_type el WHERE el.oid = t.typelem AND el.typarray = t.oid)
          AND t.oid not in (select * from extension_oids)
        ORDER BY 1, 2;
      })
    end

    def triggers(schemas = self.schemas.map{|row| row["nspname"] })
      exec(%Q{
        with extension_oids as (
          select
              objid
          from
              pg_depend d
          WHERE
             d.refclassid = 'pg_extension'::regclass and
             d.classid = 'pg_trigger'::regclass
        )
        select
            tg.tgname "name",
            nsp.nspname "schema",
            cls.relname table_name,
            pg_get_triggerdef(tg.oid) full_definition,
            proc.proname proc_name,
            nspp.nspname proc_schema,
            tg.tgenabled enabled,
            tg.oid in (select * from extension_oids) as extension_owned
        from pg_trigger tg
        join pg_class cls on cls.oid = tg.tgrelid
        join pg_namespace nsp on nsp.oid = cls.relnamespace
        join pg_proc proc on proc.oid = tg.tgfoid
        join pg_namespace nspp on nspp.oid = proc.pronamespace
        where not tg.tgisinternal
              AND nsp.nspname IN ('#{schemas.join("','")}')
        order by schema, table_name, name;
      })
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