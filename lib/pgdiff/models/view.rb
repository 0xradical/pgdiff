module PgDiff
  module Models
    class View < Base
      attr_reader :privileges

      def initialize(data, materialized = false)
        super(data)
        @materialized = materialized
        @privileges = []
      end

      def materialized?
        !!@materialized
      end

      def name
        "#{schemaname}.#{viewname}"
      end

      def id
        %Q{
          #{materialized? ? 'MATERIALIZED VIEW' : 'VIEW'} #{name}
          #{privileges.map(&:id).join("\n") if privileges.length > 0}
        }
      end

      def add_privileges(data)
        data.each do |p|
          @privileges << Models::ViewPrivilege.new(p, self)
        end
      end
    end
  end
end