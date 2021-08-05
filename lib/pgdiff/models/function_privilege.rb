module PgDiff
  module Models
    class FunctionPrivilege < Base
      attr_reader :function

      def initialize(data, function)
        super(data)
        @function = function

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

      def user
        usename
      end

      def world_type
        "FUNCTION PRIVILEGE"
      end

      # privileges don't have identities
      def world_id
        to_s
      end

      def gid
        "FUNCTION PRIVILEGE FOR #{user} ON #{function.name}"
      end

      def to_s
        "FUNCTION PRIVILEGE #{user} #{execute == 't' ? 'CAN' : 'CANNOT'} EXECUTE #{function.name}(#{function.argtypes})"
      end

      def add
        return "" if PgDiff.args.ignore_roles.include?(user)

        if execute == 't'
          %Q{GRANT EXECUTE ON FUNCTION #{function.name}(#{function.argtypes}) TO "#{user}";}
        else
          %Q{REVOKE EXECUTE ON FUNCTION #{function.name}(#{function.argtypes}) FROM "#{user}";}
        end
      end
    end
  end
end