module PgDiff
  module Models
    class Table < Base
      attr_reader :columns, :constraints, :indexes, :options, :privileges

      def initialize(data)
        super(data)
        @columns = []
        @constraints = []
        @indexes = []
        @options = []
        @privileges = []
      end

      def name
        "#{schemaname}.#{tablename}"
      end

      def owner
        tableowner
      end

      def id
        %Q{
          #{name}
          #{columns.map(&:id).join("\n") if columns.length > 0}
          #{constraints.map(&:id).join("\n") if constraints.length > 0}
        }
      end

      def add_columns(data)
        data.each do |c|
          @columns << Models::TableColumn.new(c, self)
        end
      end

      def add_constraints(data)
        data.each do |c|
          @columns << Models::TableConstraint.new(c, self)
        end
      end
    end
  end
end