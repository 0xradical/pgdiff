module PgDiff
  class Object
    attr_reader :id, :subids, :type, :schema, :name, :identity

    def initialize(id, subids, type, schema, name, identity)
      @id, @subids, @type, @schema, @name, @identity =
      id, subids, type, schema, name, identity
    end

    def eql?(other)
      id == other.id
    end

    def hash
      id.to_i
    end
  end
end