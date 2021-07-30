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

      def id
        "TABLE CONSTRAINT #{name} #{type} #{definition}"
      end
    end
  end
end
