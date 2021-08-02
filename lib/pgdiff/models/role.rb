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

      def add(diff)
        %Q{CREATE ROLE "#{name}" #{rolinherit == 't' ? 'INHERIT' : 'NOINHERIT'} #{rolcanlogin == 't' ? 'LOGIN' : 'NOLOGIN'};}
      end
    end
  end
end
