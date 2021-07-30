module PgDiff
  module Models
    class DomainConstraint < Base
      attr_reader :domain

      def initialize(data, domain)
        super(data)
        @domain = domain
      end

      def id
        "DOMAIN CONSTRAINT #{constraint_name} #{definition}"
      end

      def add
        %Q{ALTER DOMAIN "#{domain.name}" ADD CONSTRAINT #{constraint_name} #{definition};}
      end
    end
  end
end