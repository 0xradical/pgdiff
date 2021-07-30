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

      def world_type
        "TABLE"
      end


      def each
        [ columns, constraints, indexes, options, privileges ].each do |dependency|
          dependency.each { |d| yield d }
        end
      end

      def to_s
        %Q{
          TABLE #{name}
          #{columns.map(&:to_s).join("\n") if columns.length > 0}
          #{constraints.map(&:to_s).join("\n") if constraints.length > 0}
          #{indexes.map(&:to_s).join("\n") if indexes.length > 0}
          #{options.map(&:to_s).join("\n") if options.length > 0}
          #{privileges.map(&:to_s).join("\n") if privileges.length > 0}
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

      def add
        %Q{CREATE TABLE #{name} (\n} +
        [
          columns.map do |column|
            column.add
          end,
          constraints.map do |constraint|
            constraint.add
          end
        ].flatten.join(",\n") +
        %Q{);\n\n} +
        indexes.map do |index|
          index.add
        end.join("\n") +
        "\n" +
        privileges.map do |privilege|
          privilege.add
        end.join("\n") +
        "\n"
      end
    end
  end
end