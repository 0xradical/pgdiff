module PgDiff
  module Models
    class FunctionPrivilege < Base
      attr_reader :function

      def self.new(data)
        instance = allocate
        function_id = data["objid"].split(".")[0]
        if function_id && (function = PgDiff::World[data["origin"]].objects[function_id])
          instance.send(:initialize, data, function)
          instance
        else
          nil
        end
      end

      def initialize(data, function)
        @function = function
        super(data)

        function.add_privilege(self)


        world.add_dependency(
          PgDiff::Dependency.new(
            self,
            function,
            "oncreate"
          )
        )
      end

      def name
        "#{pronamespace}.#{proname}"
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
        "FUNCTION PRIVILEGE"
      end

      # privileges don't have identities
      def world_id
        to_s
      end

      def gid
        "FUNCTION PRIVILEGE ON #{function.name}(#{function.argtypes})"
      end

      def to_s
        %Q{
          FUNCTION PRIVILEGE ON #{function.name}(#{function.argtypes}) #{
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
        # return "" if PgDiff.args.ignore_roles.include?(user)
        privileges.sort_by{|user, _| user }.each do |user, privilege|
          next if PgDiff.args.ignore_roles.include?(user)

          if privilege["EXECUTE"]
            sql <<  %Q{GRANT EXECUTE ON FUNCTION #{function.name}(#{function.argtypes}) TO "#{user}";}
          else
            sql << %Q{REVOKE EXECUTE ON FUNCTION #{function.name}(#{function.argtypes}) FROM "#{user}";}
          end

          sql << "\n"
        end

        sql.join("\n")
      end
    end
  end
end