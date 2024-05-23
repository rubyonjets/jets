class Jets::CLI
  class Schedule < Jets::Thor::Base
    desc "translate", "Translate Sidekiq Schedule to Jets"
    yes_option
    def translate
      Translate.new(options).run
    end

    desc "validate", "Validate config/jets/schedule.yml"
    yes_option
    def validate
      Validate.new(options).run
    end
  end
end
