module PgDiff
  module Models
    class SequencePrivilege < Base
      attr_reader :sequence

      def initialize(data, sequence)
        super(data)
        @sequence = sequence
      end
    end
  end
end