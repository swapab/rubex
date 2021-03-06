module Rubex
  module AST
    class CBaseType
      attr_reader :type, :name, :value

      def initialize type, name, value=nil
        @type, @name, @value = type, name, value
      end

      def == other
        self.class == other.class &&
        self.type == other.class  &&
        self.name == other.name   &&
        self.value == other.value
      end
    end
  end
end
