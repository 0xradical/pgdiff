require "bundler/setup"
require_relative "../lib/pgdiff"
require "fileutils"

PgDiff.args = PgDiff::Cli.parse(ARGV)

@source = PgDiff::Database.new(
  "source",
  port: PgDiff.args.source_port,
  dbname: PgDiff.args.source_database,
  host: PgDiff.args.source_host,
  password: PgDiff.args.source_password,
  user: PgDiff.args.source_user
)

@target = PgDiff::Database.new(
  "target",
  port: PgDiff.args.target_port,
  dbname: PgDiff.args.target_database,
  host: PgDiff.args.target_host,
  password: PgDiff.args.target_password,
  user: PgDiff.args.target_user
)

PgDiff.compare(@source.world, @target.world).tap do |diff|
  if PgDiff.args.output_dir
    File.open(File.join(PgDiff.args.output_dir, [ PgDiff.args.timestamp, "-", PgDiff.args.name.gsub(/-/,'_'), ".sql" ].join("") ), "w") do |f|
      f.write(diff)
    end
  else
    puts diff
  end
end
