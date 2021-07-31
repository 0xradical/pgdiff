module PgDiff
  module Utils
    def schema_and_table(table)
      table =~ /\./ ? table.split(".") : ["public", table]
    end
  end
end