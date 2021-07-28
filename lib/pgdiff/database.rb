require_relative "catalog.rb"

module PgDiff
  class Database
    def initialize(dbparams = {})
      @pg = PG.connect(dbparams)
    end

    def catalog
      @catalog ||= PgDiff::Catalog.new(@pg)
    end
  end
end