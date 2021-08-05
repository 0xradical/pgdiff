require "fileutils"

args = PgDiff::Cli.parse(ARGV)

@source = PgDiff::Database.new(
  "source",
  port: args.source_port,
  dbname: args.source_database,
  host: args.source_host,
  password: args.source_password,
  user: args.source_user
)

@target = PgDiff::Database.new(
  "target",
  port: args.target_port,
  dbname: args.target_database,
  host: args.target_host,
  password: args.target_password,
  user: args.target_user
)

PgDiff.compare(@source.world, @target.world).tap do |diff|
  if args.output
    File.open(args.output, "w") do |f|
      f.write(diff)
    end
  else
    puts diff
  end
end
