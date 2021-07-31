module PgDiff
  module Models
    class Domain < Base
      attr_reader :constraints

      def initialize(data, constraints = [])
        super(data)
        @constraints = []
      end

      def world_type
        "TYPE"
      end

      def name
        "#{schema}.#{@data['name']}"
      end

      def each
        [ constraints ].each do |dependency|
          dependency.each { |d| yield d }
        end
      end

      def add_constraints(data)
        data.each do |c|
          @constraints << Models::DomainConstraint.new(c, self)
        end
      end

      def to_s
        %Q{
          DOMAIN #{name} AS #{data_type} #{'NOT NULL' if not_null == 't'} #{'DEFAULT ' + default if default}
          #{
            constraints.map(&:to_s).join("\n") if constraints.length > 0
          }
        }
      end

      def add(diff)
        %Q{CREATE DOMAIN "#{name}" AS #{data_type};\n} +
        constraints.map do |constraint|
          constraint.add(diff)
        end.join("\n")
      end
    end
  end
end
