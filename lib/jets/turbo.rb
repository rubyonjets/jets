require 'fileutils'
require 'memoist'

module Jets
  class Turbo
    class << self
      extend Memoist

      # Relies on the cached side-effect since Jets afterburner will switch Jets.root and the result will be different
      def afterburner?
        new.rails?
      end
      memoize :afterburner?
    end

    # Turbo charge mode
    def charge
      framework = detect
      case framework
      when :jets
        # do nothing
      when :rails
        Rails.new.setup
      else
        # should never get here
      end
    end

    def detect
      if rails?
        :rails
      elsif jets?
        :jets
      else
        :unknown_framework
      end
    end

    def rails?
      config_ru_contains?('run Rails.application')
    end

    def jets?
      config_ru_contains?('run Jets.application')
    end

    def config_ru_contains?(value)
      root = ENV["JETS_ROOT"] || Dir.pwd # Jets.root is not yet available
      config_ru = "#{root}/config.ru"
      return false unless File.exist?(config_ru)

      lines = ::IO.readlines(config_ru)
      !!lines.detect { |l| l.include?(value) }
    end
  end
end
