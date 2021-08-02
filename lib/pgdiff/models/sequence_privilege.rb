module PgDiff
  module Models
    class SequencePrivilege < Base
      OPERATIONS = [
        "select",
        "usage",
        "update"
      ].freeze

      attr_reader :sequence

      def initialize(data, sequence)
        super(data)
        @sequence = sequence
        world.add_dependency(
          PgDiff::Dependency.new(
            self,
            sequence,
            "oncreate"
          )
        )
      end

      def name
        "#{sequence_schema}.#{sequence_name}"
      end

      def user
        usename
      end

      def world_type
        "SEQUENCE PRIVILEGE"
      end

      # privileges don't have identities
      def world_id
        to_s
      end

      def gid
        "SEQUENCE PRIVILEGE FOR #{user} ON #{sequence.name}"
      end

      def to_s
        "SEQUENCE PRIVILEGE #{user} #{operations.join(", ")}"
      end

      def add
        %Q{REVOKE ALL PRIVILEGES ON #{name} FROM "#{user}";\n} +
        OPERATIONS.map do |op|
          if @data[op] == "t"
            %Q{GRANT #{op.upcase} ON #{name} TO "#{user}";}
          end
        end.compact.join("\n")
      end

      def operations
        OPERATIONS.map do |op|
          @data[op] == "t" ? "CAN #{op.upcase} ON #{name}" : "CANNOT #{op.upcase} ON #{name}"
        end
      end
    end
  end
end

# {"sequence_schema"=>"app", "sequence_name"=>"user_accounts_id_seq", "usename"=>"admin", "cache_value"=>nil, "select"=>"f", "usage"=>"f", "update"=>"f"}