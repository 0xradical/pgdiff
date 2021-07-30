module PgDiff
  module Models
    class Function < Base
      attr_reader :privileges

      def initialize(data)
        super(data)
        @privileges = []
      end

      def type
        "FUNCTION"
      end

      def add_privileges(data)
        data.each do |p|
          @privileges << Models::FunctionPrivilege.new(p, self)
        end
      end

      def name
        "#{nspname}.#{proname}"
      end

      def id
        %Q{
          #{name}(#{argtypes})
          #{
            privileges.map(&:id).join("\n") if privileges.length > 0
           }
        }
      end
    end
  end
end