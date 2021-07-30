module PgDiff
  module Models
    class Domain < Base
      attr_reader :constraints

      def initialize(data, constraints = [])
        super(data)
        @constraints = []
      end

      def name
        "#{schema}.#{@data['name']}"
      end

      def add_constraints(data)
        data.each do |c|
          @constraints << Models::DomainConstraint.new(c, self)
        end
      end

      def id
        %Q{
          DOMAIN #{name} AS #{data_type} #{'NOT NULL' if not_null == 't'} #{'DEFAULT ' + default if default}
          #{
            constraints.map(&:id).join("\n") if constraints.length > 0
          }
        }
      end

      def add
        %Q{CREATE DOMAIN "#{name}" AS #{data_type};\n} +
        constraints.map do |constraint|
          %Q{ALTER DOMAIN "#{name}" ADD constraint #{constraint.constraint_name} #{constraint.definition};}
        end.join("\n")
      end
    end
  end
end
