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

      def type
        "TYPE"
      end

      def id
        %Q{
          DOMAIN #{name} AS #{data_type} #{'NOT NULL' if not_null == 't'} #{'DEFAULT ' + default if default}
          #{
            constraints.map(&:id).join("\n") if constraints.length > 0
          }
        }
      end
    end
  end
end