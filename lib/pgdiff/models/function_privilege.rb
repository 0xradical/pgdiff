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
        "FUNCTION PRIVILEGE #{user} #{execute == 't' ? 'CAN' : 'CANNOT'} EXECUTE #{name}"
      end
    end
  end
end