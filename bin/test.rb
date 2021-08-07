@source = PgDiff::Database.new( "source", port: 54532, dbname: "pgdiff", host: "0.0.0.0", password: "postgres", user: "postgres")
@target = PgDiff::Database.new( "target", port: 54533, dbname: "pgdiff", host: "0.0.0.0", password: "postgres", user: "postgres")

File.open("pgdiff.sql", "w") do |f|
  f.write(PgDiff.compare(@source.world, @target.world))
end
