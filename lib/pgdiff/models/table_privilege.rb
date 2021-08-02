module PgDiff
  module Models
    class TablePrivilege < Base
      OPERATIONS = [
        "select",
        "insert",
        "update",
        "delete",
        "truncate",
        "references",
        "trigger"
      ].freeze

      attr_reader :table

      def initialize(data, table)
        super(data)
        @table = table

        PgDiff::World.add_dependency(
          PgDiff::Dependency.new(
            self,
            PgDiff::World::ROLES[user],
            "internal"
          )
        )
      end

      def name
        "#{schemaname}.#{tablename}"
      end

      def user
        usename
      end

      def world_type
        "TABLE PRIVILEGE"
      end

      def world_id
        to_s
      end

      def to_s
        "TABLE PRIVILEGE #{user} #{operations.join(", ")}"
      end

      def add(diff)
        %Q{REVOKE ALL PRIVILEGES ON #{name} FROM "#{user}";\n} +
        OPERATIONS.map do |op|
          if @data[op] == "t"
            %Q{GRANT #{op.upcase} ON #{name} TO "#{user}";}
          end
        end.compact.join("\n")
      end

      def operations
        OPERATIONS.map do |op|
          @data[op] == "t" ? "CAN #{op.upcase} ON #{name}" : "CANNOT #{op.upcase} ON #{name}"
        end
      end
    end
  end
end


# {"schemaname"=>"app",
#   "tablename"=>"user_accounts",
#   "usename"=>"admin",
#   "select"=>"f",
#   "insert"=>"f",
#   "update"=>"f",
#   "delete"=>"f",
#   "truncate"=>"f",
#   "references"=>"f",
#   "trigger"=>"f"},