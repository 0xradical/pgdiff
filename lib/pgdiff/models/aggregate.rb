module PgDiff
  module Models
    class Aggregate < Base
      def name
        "#{nspname}.#{proname}"
      end

      def id
        %Q{
          AGGREGATE #{name}(#{argtypes})
          #{definition}
        }
      end
    end
  end
end

# {"proname"=>"array_accum", "nspname"=>"public", "owner"=>"postgres", "argtypes"=>"anyarray", "definition"=>"\tSFUNC = array_cat,\n\tSTYPE = anyarray,\n\tSSPACE = 0,\n\tINITCOND = {},\n\tPARALLEL = UNSAFE"}