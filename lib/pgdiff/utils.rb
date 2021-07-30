module PgDiff
  module Utils
    def query(q)
      @connection.exec(q).entries
    end

    def schema_and_table(table)
      table =~ /\./ ? table.split(".") : ["public", table]
    end
  end
end