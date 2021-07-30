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
          TABLE #{name}
          #{columns.map(&:id).join("\n") if columns.length > 0}
          #{constraints.map(&:id).join("\n") if constraints.length > 0}
          #{indexes.map(&:id).join("\n") if indexes.length > 0}
          #{options.map(&:id).join("\n") if options.length > 0}
          #{privileges.map(&:id).join("\n") if privileges.length > 0}
        }
      end

      def add_columns(data)
        data.each do |c|
          @columns << Models::TableColumn.new(c, self)
        end
      end

      def add_constraints(data)
        data.each do |c|
          @constraints << Models::TableConstraint.new(c, self)
        end
      end

      def add_indexes(data)
        data.each do |c|
          @indexes << Models::TableIndex.new(c, self)
        end
      end

      def add_options(data)
        data.each do |c|
          @options << Models::TableOption.new(c, self)
        end
      end

      def add_privileges(data)
        data.each do |c|
          @privileges << Models::TablePrivilege.new(c, self)
        end
      end
    end
  end
end