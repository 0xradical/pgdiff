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

PgDiff::Destructurer.new(@source.world).destructure(PgDiff.args.output_dir)

