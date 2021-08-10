module PgDiff
  module Models
    class DomainConstraint < Base
      attr_reader :domain

      def initialize(data, domain)
        super(data)
        @domain = domain
      end

      def name
        constraint_name
      end

      def world_type
        "DOMAIN CONSTRAINT"
      end

      def to_s
        "DOMAIN CONSTRAINT #{constraint_name} #{definition}"
      end

      def ddl
        add
      end

      def add
        %Q{ALTER DOMAIN #{domain.name} ADD CONSTRAINT #{constraint_name} #{definition};}
      end

      def remove
        %Q{ALTER DOMAIN #{domain.name} DROP CONSTRAINT #{constraint_name};}
      end

      def change(target)
        sqls = []

        if target.name != name
          sqls << %{ALTER DOMAIN #{domain.name} RENAME CONSTRAINT #{target.name} TO #{name};}
        end

        sqls.join("\n")
      end
    end
  end
end