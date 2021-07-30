module PgDiff
  module Models
    class DomainConstraint < Base
      attr_reader :domain

      def initialize(data, domain)
        super(data)
        @domain = domain
      end

      def id
        "CONSTRAINT #{constraint_name} #{definition}"
      end
    end
  end
end