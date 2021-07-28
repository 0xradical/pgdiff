require "pg"

module PgDiff; end

require_relative "pgdiff/catalog.rb"
require_relative "pgdiff/database.rb"

@source = PgDiff::Database.new( port: 54532, dbname: "pgdiff", host: "0.0.0.0", password: "postgres", user: "postgres")
@target = PgDiff::Database.new( port: 54533, dbname: "pgdiff", host: "0.0.0.0", password: "postgres", user: "postgres")