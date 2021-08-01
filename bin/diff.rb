require "fileutils"

@source = PgDiff::Database.new( "source", port: 54532, dbname: "pgdiff", host: "0.0.0.0", password: "postgres", user: "postgres")
@target = PgDiff::Database.new( "target", port: 54533, dbname: "pgdiff", host: "0.0.0.0", password: "postgres", user: "postgres")

PgDiff.compare(@source, @target).tap do |diff|
  File.open("pgdiff.sql", "w") do |f|
    f.write(diff.to_sql)
  end
end
