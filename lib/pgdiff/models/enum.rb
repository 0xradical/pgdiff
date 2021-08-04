module PgDiff
  module Models
    class Enum < Base
      def name
        "#{schema}.#{@data['name']}"
      end

      def world_type
        "TYPE"
      end

      def to_s
        "ENUM #{name} #{elements}"
      end

      def change(target)
        sqls = []

        added = Set.new(elements) - Set.new(target.elements)
        removed = Set.new(target.elements) - Set.new(elements)
        original = (Set.new(elements) | Set.new(target.elements)) - added - removed

        if removed.length > 0
          deps = dependencies.others_depend_on_me.objects.map(&:gid).reject{|dep| dep == "#{gid}[]" }
          if deps.count > 0
          sqls << %Q{-- To remove a value from an ENUM type, you have to make sure
-- that there are no data in columns that use this type.
-- Then, you can safely remove it with the following query:
--
-- DELETE FROM pg_enum
--  WHERE enumlabel IN (#{removed.map{|r| '\'' + r + '\'' }})
--  AND enumtypid = (
--    SELECT oid FROM pg_type WHERE typname = '#{name}'
--  );
--
-- #{gid} has the following dependencies:
#{deps.map{|d| '-- * ' + d }.join("\n")}
}
          else
            sqls << %Q{
DELETE FROM pg_enum
  WHERE enumlabel IN (#{removed.map{|r| '\'' + r + '\'' }.join(",")})
  AND enumtypid = (
    SELECT oid FROM pg_type WHERE typname = '#{name}'
  );
            }
          end
        end

        # adding at the right position
        current = Set.new(original).to_a

        added.each do |added_enum|
          0.upto(current.length).each do |index|
            if elements.join("|").include?(Set.new(current).to_a.insert(index, added_enum).join("|"))
              if index == current.length
                sqls << %Q{ALTER TYPE #{name} ADD VALUE '#{added_enum}';}
              else
                sqls << %Q{ALTER TYPE #{name} ADD VALUE '#{added_enum}' BEFORE '#{current[index]}';}
              end
              current.insert(index, added_num)
              break
            end
          end
        end

        sqls.empty? ? "" : sqls.join("\n")
      end

      def elements
        @data['elements'][/\{(.*)\}/,1].split(/\s*,\s*/)
      end

      def add
        return "" if from_extension == "t"

        %Q{CREATE TYPE #{name} AS ENUM (\n} +
        elements.map{|e| "'#{e}'"}.map do |element|
          " #{element}"
        end.join(",\n") +
        %Q{\n);}
      end

      def remove
        return "" if from_extension == "t"

        %Q{DROP TYPE #{name};}
      end
    end
  end
end

# [{"schema"=>"app", "name"=>"api_key_status", "elements"=>"{enabled,disabled,blacklisted}"}]