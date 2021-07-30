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

      def to_s
        %Q{
          FUNCTION #{name}(#{argtypes})
          #{
            privileges.map(&:to_s).join("\n") if privileges.length > 0
           }
        }
      end

      def world_type
        "FUNCTION"
      end

      def add
        %Q{#{definition};\n} +
        privileges.map do |privilege|
          privilege.add
        end.join("\n")
      end
    end
  end
end