module PgDiff
  module Models
    class TableColumn < Base
      attr_reader :table
      # default_value_fn is set in a post-process step
      attr_accessor :default_value_fn

      def initialize(data, table)
        super(data)
        @table = table
      end

      def world_type
        "TABLE COLUMN"
      end

      def world_id
        name
      end

      def name
        attname
      end

      def type
        if typname =~ /\A#{nspname}\./
          typname
        else
          "#{nspname == 'pg_catalog' ? '' : nspname + '.'}#{typname}"
        end
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
      def default_value_text
        adsrc
      end

      def default_value
        default_value_fn || default_value_text
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

      def gid
        "TABLE COLUMN #{name} ON #{table.name}"
      end

      def to_s
        "TABLE COLUMN #{name} #{type}#{not_null ? ' NOT NULL' : ''}#{default_value ? ' DEFAULT ' + default_value : ''}"
      end

      def add
        %Q{ALTER TABLE #{table.name} ADD COLUMN #{name} #{type}#{not_null ? ' NOT NULL' : ''}#{default_value ? ' DEFAULT ' + default_value : ''};}
      end

      def remove
        %Q{ALTER TABLE #{table.name} DROP COLUMN #{name};}
      end

      def rename(newname)
        %Q{ALTER TABLE #{table.name} RENAME COLUMN #{name} TO #{newname};}
      end

      def change
        ""
      end

      def changeset(target)
        set = Set.new

        set.add(:name) if name != target.name
        set.add(:type) if type != target.type
        set.add(:not_null) if not_null != target.not_null
        set.add(:default) if default_value != target.default_value

        set
      end

      def definition
        %Q{#{name} #{type}#{not_null ? ' NOT NULL' : ''}#{default_value ? ' DEFAULT ' + default_value : ''}}
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