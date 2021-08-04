module PgDiff
  module Models
    class Table < Base
      attr_reader :columns, :constraints, :indexes, :options, :privileges, :sequences

      def initialize(data)
        super(data)
        @columns = []
        @by_columns = Hash.new
        @constraints = []
        @indexes = []
        @options = []
        @privileges = []
        @sequences = []
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

      def to_s
        %Q{
          TABLE #{name}
          #{columns.map(&:to_s).join("\n") if columns.length > 0}
          #{sequences.map(&:to_s).join("\n") if sequences.length > 0}
          #{constraints.map(&:to_s).join("\n") if constraints.length > 0}
          #{indexes.map(&:to_s).join("\n") if indexes.length > 0}
          #{options.map(&:to_s).join("\n") if options.length > 0}
          #{privileges.map(&:to_s).join("\n") if privileges.length > 0}
        }
      end

      def find_column(name)
        @by_columns[name]
      end

      def add_columns(data)
        data.each do |c|
          @columns << (Models::TableColumn.new(c, self).tap{|m| @by_columns[m.name] = m })
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

      def add_sequence(sequence)
        @sequences << sequence
      end

      def add
        %Q{CREATE TABLE #{name} (\n} +
        [
          columns.map do |column|
            "    " + column.definition
          end,
          constraints.select{|c| c.contype != "t" }.map do |constraint|
            "    " + constraint.indexdef
          end
        ].flatten.join(",\n") +
        %Q{\n);\n\n} +
        indexes.select{|idx| !constraints.map(&:name).include?(idx.name) }.map do |index|
          %Q{#{index.indexdef};}
        end.join("\n") +
        "\n\n" +
        privileges.map do |privilege|
          privilege.add
        end.join("\n")
      end

      def remove
        %Q{DROP TABLE #{name};}
      end

      def change(target)
        sqls = []

        added_columns = Set.new(columns.map(&:name)) - Set.new(target.columns.map(&:name))
        removed_columns = Set.new(target.columns.map(&:name)) - Set.new(columns.map(&:name))
        renamed_columns = Set.new

        # detect rename (changed only the name)
        if added_columns.length > 0 && removed_columns.length > 0
          added_columns.to_a.product(removed_columns.to_a).select do |added, removed|
            changeset = find_column(added).changeset(target.find_column(removed))

            if changeset.length == 1 && changeset.member?(:name)
              added_columns.delete(added)
              removed_columns.delete(removed)
              renamed_columns.add([ removed , added ])

              true
            else
              false
            end
          end
        end

        common_columns = (Set.new(columns.map(&:name)) | Set.new(target.map(&:name)))
        common_columns = common_columns - added_columns
        common_columns = common_columns - removed_columns
        common_columns = common_columns - Set.new(renamed_columns.to_a.flatten)

        added_columns.each do |column|
          sqls << find_column(column).add
        end

        removed_columns.each do |column|
          sqls << target.find_column(column).remove
        end

        renamed_columns.each do |o, n|
          sqls << target.find_column(o).rename(n)
        end

        common_columns.select do |col|
          find_column(col).to_s != target.find_column(col).to_s
        end.each do |column|
          # binding.pry

        end

        sqls.join("\n")
      end
    end
  end
end