module PgDiff
  module Models
    class Domain < Base
      attr_reader :constraints

      def initialize(data, constraints = [])
        super(data)
        @constraints = []
      end

      def world_type
        "TYPE"
      end

      def name
        "#{schema}.#{@data['name']}"
      end

      def add_constraint(constraint)
        add_constraints([constraint])
      end

      def add_constraints(data)
        data.each do |c|
          if c.is_a?(Models::DomainConstraint)
            @constraints << c
          else
            @constraints << Models::DomainConstraint.new(c, self)
          end
        end
      end

      def to_s
        %Q{DOMAIN #{name} AS #{data_type} #{'NOT NULL' if not_null == 't'} #{'DEFAULT ' + default if default}}
      end

      def add
        return "" if from_extension == "t"

        %Q{CREATE DOMAIN #{name} AS #{data_type};}
      end

      def remove
        %Q{DROP DOMAIN #{name};}
      end

      def rename(newname)
        %Q{ALTER DOMAIN #{name} RENAME TO #{name};}
      end

      def set_schema(newschema)
        %Q{ALTER DOMAIN #{name} SET SCHEMA #{schema};}
      end

      #     ALTER DOMAIN name
      #     { SET DEFAULT expression | DROP DEFAULT }
      # ALTER DOMAIN name
      #     { SET | DROP } NOT NULL
      # ALTER DOMAIN name
      #     ADD domain_constraint [ NOT VALID ]
      # ALTER DOMAIN name
      #     DROP CONSTRAINT [ IF EXISTS ] constraint_name [ RESTRICT | CASCADE ]
      # ALTER DOMAIN name
      #      RENAME CONSTRAINT constraint_name TO new_constraint_name
      # ALTER DOMAIN name
      #     VALIDATE CONSTRAINT constraint_name
      # ALTER DOMAIN name
      #     OWNER TO new_owner
      # ALTER DOMAIN name
      #     RENAME TO new_name
      # ALTER DOMAIN name
      #     SET SCHEMA new_schema
      def changeset(target)
        changes = Hash.new

        return changes if from_extension == "t"

        if target.name != name
          changes[:name] = { name: name }
        end

        if target.schema != schema
          changes[:schema] = { schema: schema }
        end

        changes
      end
    end
  end
end
