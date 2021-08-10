module PgDiff
  module Models
    class Aggregate < Base
      def name
        "#{nspname}.#{proname}"
      end

      def to_s
        %Q{
          AGGREGATE #{name}(#{argtypes})
          #{definition}
        }
      end

      def schema
        nspname
      end

      def changeset(target)
        changes = Hash.new

        if definition != target.definition
          changes[:definition] = {}
        end

        changes
      end

      def world_type
        "AGGREGATE"
      end

      def ddl
        add
      end

      def add
        %Q{CREATE AGGREGATE #{name} (#{argtypes})\n(\n} +
        %Q{#{definition}} +
        %Q{\n);}
      end

      def remove
        %Q{DROP AGGREGATE IF EXISTS #{name}(#{argtypes});}
      end
    end
  end
end

# {"proname"=>"array_accum", "nspname"=>"public", "owner"=>"postgres", "argtypes"=>"anyarray", "definition"=>"\tSFUNC = array_cat,\n\tSTYPE = anyarray,\n\tSSPACE = 0,\n\tINITCOND = {},\n\tPARALLEL = UNSAFE"}
