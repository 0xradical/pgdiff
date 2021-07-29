require "minitest/autorun"
require "pgdiff"
require "pry"

class TestPgDiff < Minitest::Test
  def setup
    @source = PgDiff::Database.new( "source", port: 54532, dbname: "pgdiff", host: "0.0.0.0", password: "postgres", user: "postgres")
    @target = PgDiff::Database.new( "target", port: 54533, dbname: "pgdiff", host: "0.0.0.0", password: "postgres", user: "postgres")
  end

  def test_schemas
    assert_equal @source.catalog.schemas.map{|h| h["nspname"] }.sort, ["app", "public"]
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
    assert_equal @source.catalog.table_privileges("app.user_accounts"), []
  end
  def test_views
    assert_equal @source.catalog.views, []
  end
  def test_view_privileges
    assert_equal @source.catalog.view_privileges, []
    # assert_empty @source.catalog.functions
  end
end




  # def schemas
  # def tables(schemas = self.schemas.map{|row| row["nspname"] })
  # def table_options(table_name)
  # def table_columns(table_name)
  # def table_constraints(table_name)
  # def table_indexes(table_name)
  # def table_privileges(table_name)
  # def views(schemas = self.schemas.map{|row| row["nspname"] })
  # def view_privileges(view_name)
  # def materialized_views(schemas = self.schemas.map{|row| row["nspname"] })
  # def view_dependencies(view_name)
  # def functions(schemas = self.schemas.map{|row| row["nspname"] })
  # def aggregates(schemas = self.schemas.map{|row| row["nspname"] })
  # def function_privileges(function_name, arg_types)
  # def sequences(schemas = self.schemas.map{|row| row["nspname"] })
  # def sequence_privileges(sequence_name)