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

      def world_type
        materialized? ? "MATERIALIZED VIEW": "VIEW"
      end

      def to_s
        %Q{
          #{materialized? ? 'MATERIALIZED VIEW' : 'VIEW'} #{name}
          #{privileges.map(&:to_s).join("\n") if privileges.length > 0}
        }
      end

      def each
        [ privileges ].each do |dependency|
          dependency.each { |d| yield d }
        end
      end

      def add_privileges(data)
        data.each do |p|
          @privileges << Models::ViewPrivilege.new(p, self)
        end
      end

      def add
        %Q{CREATE #{materialized? ? 'MATERIALIZED VIEW' : 'VIEW'} #{name} AS (\n} +
        %Q{#{definition}} +
        %Q{\n);} +
        "\n" +
        privileges.map do |privilege|
          privilege.add
        end.join("\n")
      end
    end
  end
end