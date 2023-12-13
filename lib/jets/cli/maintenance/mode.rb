class Jets::CLI::Maintenance
  class Mode < Base
    def on
      are_you_sure?
      warn "Enabling #{role_info} maintenance mode #{for_info}"
      role.on
    end

    def off
      warn "Disabling #{role_info} maintenance mode #{for_info}"
      role.off
    end

    def status
      if @options[:all]
        warn "Maintenance status for #{Jets.project.namespace}"
        puts "web #{Web.new.status}"
        puts "worker #{Worker.new.status}"
      else
        warn "#{role_info.titleize} maintenance status #{for_info}"
        puts role.status
      end
    end

    def are_you_sure?
      sure?("Will enable #{role_info} maintenance mode #{for_info}")
    end

    def role_info
      @options[:role]
    end

    def for_info
      "for #{Jets.project.namespace}"
    end

    def role
      # IE: Web or Worker
      klass = Jets::CLI::Maintenance.const_get(@options[:role].camelize)
      klass.new(@options)
    end
    memoize :role
  end
end
