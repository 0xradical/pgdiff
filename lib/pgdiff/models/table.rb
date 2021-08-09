module PgDiff
  module Models
    class Table < Base
      attr_reader :columns, :constraints, :indexes, :options, :privilege, :sequences, :triggers

      def initialize(data)
        super(data)
        @columns = []
        @by_columns = Hash.new
        @constraints = []
        @indexes = []
        @options = []
        @privilege = nil
        @sequences = []
        @triggers = []
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
        %Q{TABLE #{name}}
      end

      def find_column(name)
        @by_columns[name]
      end

      def add_column(column)
        @columns << (column.tap{|m| @by_columns[m.name] = m })
      end

      def add_privilege(privilege)
        @privilege = privilege
      end

      def add_constraint(constraint)
        @constraints << constraint
      end

      def add_index(index)
        @indexes << index
      end

      def add_trigger(trigger)
        @triggers << trigger
      end

      # def add_constraints(data)
      #   data.each do |c|
      #     @constraints << Models::TableConstraint.new(c, self)
      #   end
      # end

      # def add_indexes(data)
      #   data.each do |c|
      #     @indexes << Models::TableIndex.new(c, self)
      #   end
      # end

      def add_options(data)
        data.each do |c|
          @options << Models::TableOption.new(c, self)
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
        "\n\n"
      end

      def remove
        %Q{DROP TABLE #{name};}
      end

      def changeset(target)
        changes = Hash.new

        added_columns = Set.new(columns.map(&:gid)) - Set.new(target.columns.map(&:gid))
        removed_columns = Set.new(target.columns.map(&:gid)) - Set.new(columns.map(&:gid))
        renamed_columns = Set.new

        # detect rename (changed only the name)
        if added_columns.length > 0 && removed_columns.length > 0
          added_columns.to_a.product(removed_columns.to_a).select do |added, removed|
            changeset = world.find_by_gid(added).changeset(target.world.find_by_gid(removed))

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

        common_columns = (Set.new(columns.map(&:gid)) | Set.new(target.map(&:gid)))
        common_columns = common_columns - added_columns
        common_columns = common_columns - removed_columns
        common_columns = common_columns - Set.new(renamed_columns.to_a.flatten)

        added_columns.each do |column|
          changes[column] = { op: :add, from: self }
        end

        removed_columns.each do |column|
          changes[column] = { op: :remove, from: target }
        end

        renamed_columns.each do |o, n|
          changes[o] = { op: :rename, from: target, source: n }
        end

        common_columns.select do |col|
          world.find_by_gid(col).to_s != target.world.find_by_gid(col).to_s
        end.each do |column|
          changes[column] = { op: :diff, from: target }
        end

        changes
      end
    end
  end
end