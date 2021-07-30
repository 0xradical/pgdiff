module PgDiff
  module Models
    class TableColumn < Base
      attr_reader :table

      def initialize(data, table)
        super(data)
        @table = table
      end

      def name
        attname
      end

      def type
        "#{nspname == 'pg_catalog' ? '' : nspname + '.'}#{typname}"
      end

      def not_null
        attnotnull == "t"
      end

      def category
        typcategory
      end

      # The adsrc field is historical, and is best not used,
      # because it does not track outside changes that might affect the
      # representation of the default value.
      # Reverse-compiling the adbin field (with pg_get_expr for example) is a better way
      # to display the default value.
      def default_value
        adsrc
      end

      # Code	Category
      # A	Array types
      # B	Boolean types
      # C	Composite types
      # D	Date/time types
      # E	Enum types
      # G	Geometric types
      # I	Network address types
      # N	Numeric types
      # P	Pseudo-types
      # S	String types
      # T	Timespan types
      # U	User-defined types
      # V	Bit-string types
      # X	unknown type
      def category
        typcategory
      end

      def id
        "TABLE COLUMN #{name} #{type} #{not_null ? 'NOT NULL' : ''} #{default_value ? 'DEFAULT ' + default_value : ''}"
      end
    end
  end
end

# {"attname"=>"id",
#   "attnotnull"=>"t",
#   "typname"=>"int8",
#   "typeid"=>"20",
#   "typcategory"=>"N",
#   "adsrc"=>"nextval('app.user_accounts_id_seq'::regclass)",
#   "attidentity"=>"",
#   "precision"=>nil,
#   "scale"=>nil}