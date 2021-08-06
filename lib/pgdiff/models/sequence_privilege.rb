module PgDiff
  module Models
    class SequencePrivilege < Base
      OPERATIONS = [
        "select",
        "usage",
        "update"
      ].freeze

      attr_reader :sequence

      def self.new(data)
        instance = allocate
        sequence_id = data["objid"].split(".")[0]
        if sequence_id && (sequence = PgDiff::World[data["origin"]].objects[sequence_id])
          instance.send(:initialize, data, sequence)
          instance
        else
          nil
        end
      end

      def initialize(data, sequence)
        @sequence = sequence
        super(data)

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

      def privileges
        JSON.parse(@data['privileges']).reduce({}) do |acc, (k, h)|
          acc.merge(k => h)
        end
      end

      def users
        privileges.keys
      end

      def world_type
        "SEQUENCE PRIVILEGE"
      end

      # privileges don't have identities
      def world_id
        to_s
      end

      def gid
        "SEQUENCE PRIVILEGE ON #{sequence.name}"
      end

      def to_s
        %Q{
          SEQUENCE PRIVILEGE ON #{sequence.name} #{
            users.sort.map do |user|
              privileges[user].sort_by {|k,v| k}.map do |k,v|
                v ? "#{user} CAN #{k}" : "#{user} CANNOT #{k}"
              end.join("\n")
            end.join("\n")
          }
        }
      end

      def add
        return "" if PgDiff.args.ignore_roles.include?(user)

        %Q{REVOKE ALL PRIVILEGES ON #{name} FROM "#{user}";\n} +
        OPERATIONS.map do |op|
          if @data[op] == "t"
            %Q{GRANT #{op.upcase} ON #{name} TO "#{user}";}
          end
        end.compact.join("\n")
      end
    end
  end
end

# {"sequence_schema"=>"app", "sequence_name"=>"user_accounts_id_seq", "usename"=>"admin", "cache_value"=>nil, "select"=>"f", "usage"=>"f", "update"=>"f"}