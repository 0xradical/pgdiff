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

        sequence.add_privilege(self)

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
        JSON.parse(@data['privileges']).reduce({}) do |acc, h|
          acc.merge(h.keys[0] => h.values[0])
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

      def ddl
        add
      end

      def add
        sql = []
        privileges.each do |user, user_privileges|
          next if PgDiff.args.ignore_roles.include?(user)

          sql << %Q{REVOKE ALL PRIVILEGES ON #{name} FROM "#{user}";}

          user_privileges.each_pair do |operation, can|
            if can
              sql << %Q{GRANT #{operation} ON #{name} TO "#{user}";}
            end
          end
        end

        sql.join("\n")
      end
    end
  end
end

# {"sequence_schema"=>"app", "sequence_name"=>"user_accounts_id_seq", "usename"=>"admin", "cache_value"=>nil, "select"=>"f", "usage"=>"f", "update"=>"f"}