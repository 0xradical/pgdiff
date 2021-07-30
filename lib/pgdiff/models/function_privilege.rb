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

      def id
        "#{usename} #{execute == 't' ? 'CAN' : 'CANNOT'} EXECUTE #{name}"
      end
    end
  end
end