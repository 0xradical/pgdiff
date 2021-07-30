require "minitest/autorun"
require "pgdiff"
require "pry"

class TestPgDiff < Minitest::Test
  def setup
    @source = PgDiff::Database.new( "source", port: 54532, dbname: "pgdiff", host: "0.0.0.0", password: "postgres", user: "postgres")
    @target = PgDiff::Database.new( "target", port: 54533, dbname: "pgdiff", host: "0.0.0.0", password: "postgres", user: "postgres")
  end

  def test_schemas
    assert_equal @source.catalog.schemas.map{|h| h["nspname"] }.sort, ["api", "app", "funcs", "public"]
  end
  def test_tables
    assert_equal @source.catalog.tables, [
      {"schemaname"=>"app",
      "tablename"=>"user_accounts",
      "tableowner"=>"postgres"}
    ]
  end
  def test_table_options
    assert_equal @source.catalog.table_options("app.user_accounts"), [{"relhasoids"=>"f"}]
  end
  def test_table_columns
    assert_equal @source.catalog.table_columns("app.user_accounts"), [{
      "attname"=>"id",
      "attnotnull"=>"t",
      "typname"=>"int8",
      "typeid"=>"20",
      "typcategory"=>"N",
      "adsrc"=>"nextval('app.user_accounts_id_seq'::regclass)",
      "attidentity"=>"",
      "precision"=>nil,
      "scale"=>nil
    }, {
      "attname"=>"email",
      "attnotnull"=>"t",
      "typname"=>"varchar",
      "typeid"=>"1043",
      "typcategory"=>"S",
      "adsrc"=>"''::character varying", "attidentity"=>"",
      "precision"=>nil,
      "scale"=>nil
    }, {
      "attname"=>"encrypted_password",
      "attnotnull"=>"t",
      "typname"=>"varchar",
      "typeid"=>"1043",
      "typcategory"=>"S",
      "adsrc"=>"''::character varying",
      "attidentity"=>"",
      "precision"=>nil,
      "scale"=>nil
    }, {
      "attname"=>"preferences",
      "attnotnull"=>"f",
      "typname"=>"json",
      "typeid"=>"114",
      "typcategory"=>"U",
      "adsrc"=>"'{}'::json",
      "attidentity"=>"",
      "precision"=>nil,
      "scale"=>nil
    }, {
      "attname"=>"login_attempts",
      "attnotnull"=>"t",
      "typname"=>"int4",
      "typeid"=>"23",
      "typcategory"=>"N",
      "adsrc"=>"0",
      "attidentity"=>"",
      "precision"=>nil,
      "scale"=>nil
    }, {
      "attname"=>"created_at",
      "attnotnull"=>"t",
      "typname"=>"timestamptz",
      "typeid"=>"1184",
      "typcategory"=>"D",
      "adsrc"=>"now()",
      "attidentity"=>"",
      "precision"=>nil,
      "scale"=>nil
    }, {
      "attname"=>"updated_at",
      "attnotnull"=>"t",
      "typname"=>"timestamptz",
      "typeid"=>"1184",
      "typcategory"=>"D",
      "adsrc"=>"now()",
      "attidentity"=>"",
      "precision"=>nil,
      "scale"=>nil
    }]
  end
  def test_table_constraints
    assert_equal @source.catalog.table_constraints("app.user_accounts"), [{
      "conname"=>"user_accounts_pkey",
      "contype"=>"p",
      "definition"=>"PRIMARY KEY (id)"
    }]
  end
  def test_table_privileges
    assert_equal @source.catalog.table_privileges("app.user_accounts"), [{
      "schemaname"=>"app",
      "tablename"=>"user_accounts",
      "usename"=>"postgres",
      "select"=>"t",
      "insert"=>"t",
      "update"=>"t",
      "delete"=>"t",
      "truncate"=>"t",
      "references"=>"t",
      "trigger"=>"t"
    }, {
      "schemaname"=>"app",
      "tablename"=>"user_accounts",
      "usename"=>"admin",
      "select"=>"f",
      "insert"=>"f",
      "update"=>"f",
      "delete"=>"f",
      "truncate"=>"f",
      "references"=>"f",
      "trigger"=>"f"
      }, {
      "schemaname"=>"app",
      "tablename"=>"user_accounts",
      "usename"=>"user",
      "select"=>"f",
      "insert"=>"f",
      "update"=>"f",
      "delete"=>"f",
      "truncate"=>"f",
      "references"=>"f",
      "trigger"=>"f"
    }]
  end
  def test_views
    assert_equal @source.catalog.views,  [{
      "schemaname"=>"api",
      "viewname"=>"user_accounts",
      "viewowner"=>"postgres",
      "definition"=>
        " SELECT user_accounts.id,\n    user_accounts.email,\n    user_accounts.encrypted_password,\n    user_accounts.preferences,\n    user_accounts.login_attempts,\n    user_accounts.created_at,\n    user_accounts.updated_at\n   FROM app.user_accounts\n  WHERE (user_accounts.created_at >= '2020-01-01 00:00:00+00'::timestamp with time zone);"
    }]
  end

  def test_view_privileges
    assert_equal @source.catalog.view_privileges("api.user_accounts"), [{
      "schemaname"=>"api",
      "viewname"=>"user_accounts",
      "usename"=>"postgres",
      "select"=>"t",
      "insert"=>"t",
      "update"=>"t",
      "delete"=>"t",
      "truncate"=>"t",
      "references"=>"t",
      "trigger"=>"t"
    }, {
      "schemaname"=>"api",
       "viewname"=>"user_accounts",
       "usename"=>"admin",
       "select"=>"f",
       "insert"=>"f",
       "update"=>"f",
       "delete"=>"f",
       "truncate"=>"f",
       "references"=>"f",
       "trigger"=>"f"
    }, {
      "schemaname"=>"api",
      "viewname"=>"user_accounts",
      "usename"=>"user",
      "select"=>"f",
      "insert"=>"f",
      "update"=>"f",
      "delete"=>"f",
      "truncate"=>"f",
      "references"=>"f",
      "trigger"=>"f"
    }]
  end

  def test_functions
    assert_equal @source.catalog.functions, [{
      "proname"=>"answer_to_life",
      "nspname"=>"funcs",
      "definition"=>
      "CREATE OR REPLACE FUNCTION funcs.answer_to_life()
 RETURNS text
 LANGUAGE plv8
AS $function$
    // a comment inside the function
    return 42;
  $function$
",
    "owner"=>"postgres",
    "argtypes"=>""
    },{
      "proname"=>"user_account_instead_of_insert",
      "nspname"=>"api",
      "definition"=>"CREATE OR REPLACE FUNCTION api.user_account_instead_of_insert()
 RETURNS trigger
 LANGUAGE plv8
AS $function$
    var user = plv8.execute()[0];
    return user;
  $function$
",
      "owner"=>"postgres",
      "argtypes"=>""
    }]
  end

  def test_aggregates
    assert_equal @source.catalog.aggregates, [{
      "proname"=>"array_accum",
      "nspname"=>"public",
      "owner"=>"postgres",
      "argtypes"=>"anyarray",
      "definition"=>
      "\tSFUNC = array_cat,
\tSTYPE = anyarray,
\tSSPACE = 0,
\tINITCOND = {},
\tPARALLEL = UNSAFE"
    }]
  end

  def test_function_privileges
    assert_equal @source.catalog.function_privileges("funcs.answer_to_life", ""), [{
      "pronamespace"=>"funcs",
      "proname"=>"answer_to_life",
      "usename"=>"postgres",
      "execute"=>"t"
    }, {
      "pronamespace"=>"funcs",
      "proname"=>"answer_to_life",
      "usename"=>"admin",
      "execute"=>"t"
    }, {
      "pronamespace"=>"funcs",
      "proname"=>"answer_to_life",
      "usename"=>"user",
      "execute"=>"t"
    }]
  end

  def test_sequences
    assert_equal @source.catalog.sequences, [{
      "seq_nspname"=>"app",
      "seq_name"=>"user_accounts_id_seq",
      "owner"=>"postgres",
      "ownedby_table"=>"user_accounts",
      "ownedby_column"=>"id",
      "start_value"=>"1",
      "minimum_value"=>"1",
      "maximum_value"=>"9223372036854775807",
      "increment"=>"1",
      "cycle_option"=>"f",
      "cache_size"=>"1"
    }]
  end

  def test_sequence_privileges
    assert_equal @source.catalog.sequence_privileges("app.user_accounts_id_seq"), [{
      "sequence_schema"=>"app",
      "sequence_name"=>"user_accounts_id_seq",
      "usename"=>"postgres",
      "cache_value"=>nil,
      "select"=>"t",
      "usage"=>"t",
      "update"=>"t"
    }, {
      "sequence_schema"=>"app",
      "sequence_name"=>"user_accounts_id_seq",
      "usename"=>"admin",
      "cache_value"=>nil,
      "select"=>"f",
      "usage"=>"f",
      "update"=>"f"
    }, {
      "sequence_schema"=>"app",
      "sequence_name"=>"user_accounts_id_seq",
      "usename"=>"user",
      "cache_value"=>nil,
      "select"=>"f",
      "usage"=>"f",
      "update"=>"f"
    }]
  end

  def test_enums
    assert_equal @source.catalog.enums, [{
      "schema"=>"app",
      "name"=>"api_key_status",
      "elements"=>"{enabled,disabled,blacklisted}"
    }]
  end

  def test_domains
    assert_equal @source.catalog.domains, [{
      "schema"=>"app",
      "name"=>"domain",
      "data_type"=>"citext",
      "type"=>"domain",
      "collation"=>nil,
      "not_null"=>"f",
      "default"=>nil
    }, {
      "schema"=>"app",
      "name"=>"username",
      "data_type"=>"citext",
      "type"=>"domain",
      "collation"=>nil,
      "not_null"=>"f",
      "default"=>nil
    }]
  end

  def test_domain_constraints
    assert_equal @source.catalog.domain_constraints("app.domain"), [{
      "constraint_name"=>"domain__must_be_a_domain",
      "definition"=>"CHECK (VALUE ~ '^([a-z0-9\\-\\_]+\\.)+[a-z]+$'::citext)"
    }]
  end

  def test_triggers
    assert_equal @source.catalog.triggers, [{
      "name"=>"api_user_account_instead_of_insert",
      "schema"=>"api",
      "table_name"=>"user_accounts",
      "full_definition"=>"CREATE TRIGGER api_user_account_instead_of_insert INSTEAD OF INSERT ON api.user_accounts FOR EACH ROW EXECUTE PROCEDURE api.user_account_instead_of_insert()",
      "proc_name"=>"user_account_instead_of_insert",
      "proc_schema"=>"api",
      "enabled"=>"O",
      "extension_owned"=>"f"
    }]
  end
end
