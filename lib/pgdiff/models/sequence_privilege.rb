module PgDiff
  module Models
    class SequencePrivilege < Base
      attr_reader :sequence

      def initialize(data, sequence)
        super(data)
        @sequence = sequence
      end

      def name
        "#{sequence_schema}.#{sequence_name}"
      end

      def user
        usename
      end

      def id
        "SEQUENCE PRIVILEGE #{user} #{operations.join(", ")}"
      end

      def operations
        [
          "select",
          "usage",
          "update"
        ].map do |op|
          @data[op] == "t" ? "CAN #{op.upcase} ON #{name}" : "CANNOT #{op.upcase} ON #{name}"
        end
      end
    end
  end
end

# {"sequence_schema"=>"app", "sequence_name"=>"user_accounts_id_seq", "usename"=>"admin", "cache_value"=>nil, "select"=>"f", "usage"=>"f", "update"=>"f"}