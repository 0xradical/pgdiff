module PgDiff
  module Models
    class Sequence < Base
      attr_reader :privilege

      def initialize(data)
        super(data)
        @privilege = nil
      end

      def name
        "#{seq_nspname}.#{seq_name}"
      end

      def world_type
        "SEQUENCE"
      end

      def to_s
        %Q{SEQUENCE #{name}}
      end

      def add_privilege(privilege)
        @privilege = privilege
      end

      def add
        %Q{CREATE SEQUENCE IF NOT EXISTS #{name}
  INCREMENT BY #{increment}
  MINVALUE #{minimum_value}
  MAXVALUE #{maximum_value}
  START WITH #{start_value}
  CACHE #{cache_size} #{cycle_option == "f" ? 'NO CYCLE' : 'CYCLE'};}
      end

      def changeset(target)
        changes =  Hash.new

        changes
      end

      def remove
        ""
      end
    end
  end
end

# [{"seq_nspname"=>"app",
#   "seq_name"=>"user_accounts_id_seq",
#   "owner"=>"postgres",
#   "ownedby_table"=>"user_accounts",
#   "ownedby_column"=>"id",
#   "start_value"=>"1",
#   "minimum_value"=>"1",
#   "maximum_value"=>"9223372036854775807",
#   "increment"=>"1",
#   "cycle_option"=>"f",
#   "cache_size"=>"1"}]