module PgDiff
  module Models
    class TableConstraint < Base
      attr_reader :table

      def initialize(data, table)
        super(data)
        @table = table
      end

      def name
        conname
      end

      # c = check constraint,
      # f = foreign key constraint,
      # p = primary key constraint,
      # u = unique constraint,
      # t = constraint trigger,
      # x = exclusion constraint
      def type
        {
          "c" => "CHECK",
          "f" => "FOREIGN KEY",
          "p" => "PRIMARY KEY",
          "u" => "UNIQUE",
          "t" => "TRIGGER",
          "x" => "EXCLUSION"
        }.fetch(contype, "UNKNOWN")
      end

      def to_s
        "TABLE CONSTRAINT #{name} #{type} #{definition}"
      end

      def world_type
        "TABLE CONSTRAINT"
      end

      def add(diff)
        %Q{CONSTRAINT #{name} #{definition}}
      end
    end
  end
end
