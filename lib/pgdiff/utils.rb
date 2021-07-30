module PgDiff
  module Utils
    def exec(query)
      @connection.exec(query).entries
    end

    def schema_and_table(table)
      table =~ /\./ ? table.split(".") : ["public", table]
    end
  end
end