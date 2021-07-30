module PgDiff
  module Models
    class FunctionPrivilege < Base
      attr_reader :function

      def initialize(data, function)
        super(data)
        @function = function
      end

      def name
        "#{pronamespace}.#{proname}"
      end

      def user
        usename
      end

      def id
        "FUNCTION PRIVILEGE #{user} #{execute == 't' ? 'CAN' : 'CANNOT'} EXECUTE #{name}(#{argtypes})"
      end

      def add
        if execute == 't'
          %Q{GRANT EXECUTE ON #{name}(#{argtypes}) TO "#{user}";}
        else
          %Q{REVOKE EXECUTE ON #{name}(#{argtypes}) FROM "#{user}";}
        end
      end
    end
  end
end