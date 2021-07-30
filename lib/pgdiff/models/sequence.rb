module PgDiff
  module Models
    class Sequence < Base
      attr_reader :privileges

      def initialize(data)
        super(data)
        @privileges = []
      end

      def name
        "#{seq_nspname}.#{seq_name}"
      end

      def id
        %Q{
          SEQUENCE #{name}
          #{privileges.map(&:id).join("\n") if privileges.length > 0}
        }
      end

      def add_privileges(data)
        data.each do |p|
          @privileges << Models::SequencePrivilege.new(p, self)
        end
      end

      def add
        %Q{CREATE SEQUENCE IF NOT EXISTS #{name}
  INCREMENT BY #{increment}
  MINVALUE #{minimum_value}
  MAXVALUE #{maximum_value}
  START #{start_value}
  CACHE #{cache_size} #{cycle_option == "f" ? 'NOCYCLE' : 'CYCLE'};\n
        } +
        privileges.map do |privilege|
          privilege.add
        end.join("\n")
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