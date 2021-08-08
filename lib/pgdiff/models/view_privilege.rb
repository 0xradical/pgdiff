module PgDiff
  module Models
    class ViewPrivilege < Base
      OPERATIONS = [
        "select",
        "insert",
        "update",
        "delete",
        "truncate",
        "references",
        "trigger"
      ].freeze

      attr_reader :view

      def self.new(data)
        instance = allocate
        view_id = data["objid"].split(".")[0]
        if view_id && (view = PgDiff::World[data["origin"]].objects[view_id])
          instance.send(:initialize, data, view)
          instance
        else
          nil
        end
      end

      def initialize(data, view)
        @view = view
        super(data)

        view.add_privilege(self)

        world.add_dependency(
          PgDiff::Dependency.new(
            self,
            view,
            "oncreate"
          )
        )
      end

      def name
        "#{schemaname}.#{viewname}"
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
        "VIEW PRIVILEGE"
      end

      def world_id
        to_s
      end

      def gid
        "VIEW PRIVILEGE ON #{view.name}"
      end

      def to_s
        %Q{
          VIEW PRIVILEGE ON #{view.name} #{
            users.sort.map do |user|
              privileges[user].sort_by {|k,v| k}.map do |k,v|
                v ? "#{user} CAN #{k}" : "#{user} CANNOT #{k}"
              end.join("\n")
            end.join("\n")
          }
        }
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


# {"schemaname"=>"api",
#   "viewname"=>"user_accounts",
#   "usename"=>"postgres",
#   "select"=>"t",
#   "insert"=>"t",
#   "update"=>"t",
#   "delete"=>"t",
#   "truncate"=>"t",
#   "references"=>"t",
#   "trigger"=>"t"}