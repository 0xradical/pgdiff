module PgDiff
  module Models
    class Function < Base
      attr_reader :privilege

      def initialize(data)
        super(data)
      end

      def type
        "FUNCTION"
      end

      def add_privilege(privilege)
        @privilege = privilege
      end

      def name
        "#{nspname}.#{proname}"
      end

      def to_s
        %Q{FUNCTION #{name}(#{argtypes})}
      end

      def world_type
        "FUNCTION"
      end

      def ddl
        add
      end

      def add
        return "" if extension_function == "t"

        %Q{#{definition};\n}
      end

      def remove
        return "" if extension_function == "t"

        %Q{DROP FUNCTION IF EXISTS #{name}(#{argtypes});}
      end

      def changeset(target)
        changes = Hash.new

        return changes if extension_function == "t"
        return changes if name =~ /\A(pg_catalog|information_schema)\./

        if definition != target.definition
          changes[:definition] = {}
        end

        changes
      end
    end
  end
end