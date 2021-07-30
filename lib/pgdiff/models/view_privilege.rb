module PgDiff
  module Models
    class ViewPrivilege < Base
      attr_reader :view

      def initialize(data, view)
        super(data)
        @view = view
      end

      def name
        "#{schemaname}.#{viewname}"
      end

      def user
        usename
      end

      def id
        "VIEW PRIVILEGE #{user} #{operations.join(", ")}"
      end

      def operations
        [
          "select",
          "insert",
          "update",
          "delete",
          "truncate",
          "references",
          "trigger"
        ].map do |op|
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