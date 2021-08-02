module PgDiff
  module Models
    class DomainConstraint < Base
      attr_reader :domain

      def initialize(data, domain)
        super(data)
        @domain = domain
      end

      def world_type
        "DOMAIN CONSTRAINT"
      end

      def gid
        "DOMAIN CONSTRAINT ON #{domain.name}"
      end

      def to_s
        "DOMAIN CONSTRAINT #{constraint_name} #{definition}"
      end

      def add
        %Q{ALTER DOMAIN "#{domain.name}" ADD CONSTRAINT #{constraint_name} #{definition};}
      end
    end
  end
end