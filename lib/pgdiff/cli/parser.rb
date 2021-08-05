require 'optparse'

module PgDiff
  module Cli
    class Parser
      def self.parse(options)
        args = Options.default

        opt_parser = OptionParser.new do |opts|
          opts.banner = "Usage: pgdiff.rb [options]"
          opts.separator ""

          opts.on_tail("-h", "--help", "Prints this help") do
            puts opts
            exit
          end
          opts.on_tail("--version", "Show version") do
            puts PgDiff::VERSION
            exit
          end
          opts.on("--ignore-roles x,y,z", Array, "Ignore these roles when processing diff") do |list|
            args.ignore_roles = list
          end
          opts.on("-d", "--dry-run", "Run verbosely") do |v|
            args.dry_run = v
          end
          opts.on("--source-host HOST", "Source db host") do |opt|
            args.source_host = opt
          end
          opts.on("--source-database DATABASE", "Source db name") do |opt|
            args.source_database = opt
          end
          opts.on("--source-port [PORT]", "Source db port (default: 5432)") do |opt|
            args.source_port = opt
          end
          opts.on("--source-password PASSWORD", "Source db password") do |opt|
            args.source_password = opt
          end
          opts.on("--source-user HOST", "Source db host") do |opt|
            args.source_user = opt
          end
          opts.on("--target-host HOST", "Target db host") do |opt|
            args.target_host = opt
          end
          opts.on("--target-database DATABASE", "Target db name") do |opt|
            args.target_database = opt
          end
          opts.on("--target-port [PORT]", "Target db port (default: 5432)") do |opt|
            args.target_port = opt
          end
          opts.on("--target-password PASSWORD", "Target db password") do |opt|
            args.target_password = opt
          end
          opts.on("--target-user USER", "Target db user") do |opt|
            args.target_user = opt
          end
          opts.on("--output [FILE]", "Optional output file (default: stdout)") do |opt|
            args.output = opt
          end
        end

        begin
          opt_parser.parse!
          mandatory = [
            :source_host,
            :source_database,
            :source_password,
            :source_user,
            :target_host,
            :target_database,
            :target_password,
            :target_user
          ]
          missing = mandatory.select{ |param| args.send(param).nil? || args.send(param).to_s.empty?  }
          raise OptionParser::MissingArgument, missing.map{|a| a.to_s.gsub(/_/,'-') }.join(', ') unless missing.empty?

          return args
        rescue OptionParser::ParseError => e
          puts e
          puts opt_parser
          exit
        end
      end
    end
  end
end