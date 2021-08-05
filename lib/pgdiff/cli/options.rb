module PgDiff
  module Cli
    class Options < Struct.new(
      :source_host,
      :source_database,
      :source_port,
      :source_password,
      :source_user,
      :target_host,
      :target_database,
      :target_port,
      :target_password,
      :target_user,
      :dry_run,
      :ignore_roles,
      :output
    )
      def self.default
        self.new(
          nil,
          nil,
          5432,
          nil,
          nil,
          nil,
          nil,
          5432,
          nil,
          nil,
          false,
          [],
          nil
        )
      end
    end
  end
end