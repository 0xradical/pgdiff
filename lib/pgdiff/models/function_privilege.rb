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
            world.roles[user],
            "internal"
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

      def to_s
        "FUNCTION PRIVILEGE #{user} #{execute == 't' ? 'CAN' : 'CANNOT'} EXECUTE #{name}(#{argtypes})"
      end

      def add(diff)
        if execute == 't'
          %Q{GRANT EXECUTE ON #{name}(#{argtypes}) TO "#{user}";}
        else
          %Q{REVOKE EXECUTE ON #{name}(#{argtypes}) FROM "#{user}";}
        end
      end
    end
  end
end