module PgDiff
  module Models
    class View < Base
      attr_reader :privilege

      def initialize(data)
        super(data)
        @privilege = nil
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
        %Q{#{materialized? ? 'MATERIALIZED VIEW' : 'VIEW'} #{name}}
      end

      def add_privilege(privilege)
        @privilege = privilege
      end

      def add
        %Q{CREATE #{materialized? ? 'MATERIALIZED VIEW' : 'VIEW'} #{name} AS \n} +
        %Q{#{definition}}
      end

      def remove
        %Q{DROP #{materialized? ? 'MATERIALIZED VIEW' : 'VIEW'} #{name};}
      end
    end
  end
end