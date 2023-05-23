# frozen_string_literal: true

module Jets
  class Engine < Turbine
    class Turbines
      include Enumerable
      attr_reader :_all

      def initialize
        @_all ||= ::Jets::Turbine.subclasses.map(&:instance) +
          ::Jets::Engine.subclasses.map(&:instance)
      end

      def each(*args, &block)
        _all.each(*args, &block)
      end

      def -(others)
        _all - others
      end
    end
  end
end
