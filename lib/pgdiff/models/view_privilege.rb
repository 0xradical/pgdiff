module PgDiff
  module Models
    class ViewPrivilege < Base
      OPERATIONS = [
        "select",
        "insert",
        "update",
        "delete",
        "truncate",
        "references",
        "trigger"
      ].freeze

      attr_reader :view

      def initialize(data, view)
        super(data)
        @view = view

        world.add_dependency(
          PgDiff::Dependency.new(
            self,
            view,
            "oncreate"
          )
        )
      end

      def name
        "#{schemaname}.#{viewname}"
      end

      def user
        usename
      end

      def world_type
        "VIEW PRIVILEGE"
      end

      def world_id
        to_s
      end

      def gid
        "VIEW PRIVILEGE FOR #{user} ON #{view.name}"
      end

      def to_s
        "VIEW PRIVILEGE #{user} #{operations.join(", ")}"
      end

      def add
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


# {"schemaname"=>"api",
#   "viewname"=>"user_accounts",
#   "usename"=>"postgres",
#   "select"=>"t",
#   "insert"=>"t",
#   "update"=>"t",
#   "delete"=>"t",
#   "truncate"=>"t",
#   "references"=>"t",
#   "trigger"=>"t"}