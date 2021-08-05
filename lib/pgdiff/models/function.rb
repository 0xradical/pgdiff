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
          privilege = Models::FunctionPrivilege.new(p, self)
          @privileges << privilege unless PgDiff.args.ignore_roles.include?(privilege.user)
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

      def each
        [ privileges ].each do |dependency|
          dependency.each { |d| yield d }
        end
      end

      def world_type
        "FUNCTION"
      end

      def add
        return "" if extension_function == "t"

        %Q{#{definition};\n} +
        privileges.map do |privilege|
          privilege.add
        end.join("\n")
      end

      def remove
        return "" if extension_function == "t"

        %Q{DROP FUNCTION IF EXISTS #{name}(#{argtypes});}
      end

      def change(from)
        return "" if extension_function == "t"
        return "" if name =~ /\A(pg_catalog|information_schema)\./ && definition == from.definition

        add
      end
    end
  end
end