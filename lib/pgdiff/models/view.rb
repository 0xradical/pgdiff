module PgDiff
  module Models
    class View < Base
      attr_reader :privileges

      def initialize(data)
        super(data)
        @privileges = []
      end

      def materialized?
        @data['viewtype'] == 'MATERIALIZED'
      end

      def name
        "#{schemaname}.#{viewname}"
      end

      def world_type
        materialized? ? "MATERIALIZED VIEW": "VIEW"
      end

      def to_s
        %Q{
          #{materialized? ? 'MATERIALIZED VIEW' : 'VIEW'} #{name}
          #{privileges.map(&:to_s).join("\n") if privileges.length > 0}
        }
      end

      def add_privileges(data)
        data.each do |p|
          @privileges << Models::ViewPrivilege.new(p, self)
        end
      end

      def add
        %Q{CREATE #{materialized? ? 'MATERIALIZED VIEW' : 'VIEW'} #{name} AS \n} +
        %Q{#{definition}} +
        %Q{\n} +
        privileges.map do |privilege|
          privilege.add
        end.join("\n")
      end

      def remove
        %Q{DROP #{materialized? ? 'MATERIALIZED VIEW' : 'VIEW'} #{name};}
      end
    end
  end
end