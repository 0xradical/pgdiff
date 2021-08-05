require "fileutils"

@source = PgDiff::Database.new(
  "source",
  port: ENV["SOURCE_PORT"] || 5432,
  dbname: ENV["SOURCE_DATABASE"],
  host: ENV["SOURCE_HOST"],
  password: ENV["SOURCE_PASSWORD"],
  user: ENV["SOURCE_USER"]
)

@target = PgDiff::Database.new(
  "target",
  port: ENV["TARGET_PORT"] || 5432,
  dbname: ENV["TARGET_DATABASE"],
  host: ENV["TARGET_HOST"],
  password: ENV["TARGET_PASSWORD"],
  user: ENV["TARGET_USER"]
)

PgDiff.compare(@source.world, @target.world).tap do |diff|
  File.open(ARGV[0], "w") do |f|
    f.write(diff)
  end
end
