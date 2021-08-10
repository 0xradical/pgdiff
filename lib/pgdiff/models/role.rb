module PgDiff
  module Models
    class Role < Base
      def initialize(data)
        super(data)
      end

      def name
        rolname
      end

      def world_type
        "ROLE"
      end

      def to_s
        %Q{ROLE "#{name}" #{rolinherit == 't' ? 'INHERIT' : 'NOINHERIT'} #{rolcanlogin == 't' ? 'LOGIN' : 'NOLOGIN'}}
      end

      def ddl
        add
      end

      def add
        return "" if PgDiff.args.ignore_roles.include?(name)

        %Q{CREATE ROLE "#{name}" #{rolinherit == 't' ? 'INHERIT' : 'NOINHERIT'} #{rolcanlogin == 't' ? 'LOGIN' : 'NOLOGIN'};}
      end

      def remove
        return "" if PgDiff.args.ignore_roles.include?(name)

        %Q{DROP ROLE "#{name}";}
      end
    end
  end
end
