require "pg"

module PgDiff; end

require_relative "models/base.rb"
require_relative "models/function.rb"
require_relative "models/table.rb"
require_relative "models/schema.rb"
require_relative "models/view.rb"
require_relative "models/type.rb"
require_relative "models/sequence.rb"
require_relative "models/domain.rb"
require_relative "pgdiff/catalog.rb"
require_relative "pgdiff/database.rb"