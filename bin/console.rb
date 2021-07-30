@source = PgDiff::Database.new( "source", port: 54532, dbname: "pgdiff", host: "0.0.0.0", password: "postgres", user: "postgres")
@target = PgDiff::Database.new( "target", port: 54533, dbname: "pgdiff", host: "0.0.0.0", password: "postgres", user: "postgres")

# puts PgDiff.compare(@source, @target).join("\n")