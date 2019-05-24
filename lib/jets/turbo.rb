require 'fileutils'

module Jets
  class Turbo
    # Turbo charge mode
    def charge
      framework = detect
      case framework
      when :jets
        # do nothing
      when :rails
        Rail.new.setup
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
      config_ru = "#{Dir.pwd}/config.ru"
      return false unless File.exist?(config_ru)

      lines = ::IO.readlines(config_ru)
      lines.detect { |l| l.include?(value) }
    end
  end
end
