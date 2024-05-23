class Jets::CLI::Schedule
  class Translate < Base
    def run
      are_you_sure?
      check_exist!
      success = perform
      if success
        finish_message
      else
        log.error "Translation failed."
        exit 1
      end
    end

    # interface method: used by deploy to translate on_deploy
    def perform
      # Currently only sidekiq is supported
      sidekiq = YAML.load_file("config/sidekiq.yml")
      sidekiq = ActiveSupport::HashWithIndifferentAccess.new(sidekiq)
      schedule = sidekiq[:schedule]
      unless schedule
        log.error "config/sidekiq.yml does not have a schedule key. Nothing to translate."
        return false
      end

      log.info "Translating config/sidekiq.yml => config/jets/schedule.yml"
      mapped = schedule.map do |k, v|
        translate_item(k, v)
      end
      schedule = mapped.inject({}) { |h, v| h.merge(v) }
      text = schedule.deep_stringify_keys!

      unless @@has_errors
        FileUtils.mkdir_p("config/jets")
        IO.write("config/jets/schedule.yml", YAML.dump(text))
      end
      !@@has_errors
    end

    JETS_FIELDS = %w[
      args
      class
      cron
      rate
      splat_args
    ]
    SUPPORTED_FIELDS = JETS_FIELDS + %w[
      keyword_arguments
      every
      interval
    ]

    # Example:
    #   hard_worker:
    #     class: "HardWorker"
    #     args: ["bob", 5]
    #     description: "This is a description of the job"
    #     cron: "30 6 * *
    def translate_item(key, original)
      result = {}
      result[:args] = original[:args] if original[:args]
      result[:class] = original[:class] if original[:class]
      result[:splat_args] = true if original[:keyword_arguments]
      add_schedule_expression!(result, original)
      unsupported_fields!(result, original)
      {key => result}
    end

    def add_schedule_expression!(result, original)
      if original[:cron]
        result[:cron] = cron(original[:cron])
      elsif original[:every]
        handle_every_expression!(result, original[:every])
      elsif original[:interval]
        handle_every_expression!(result, original[:interval])
      end
    end

    @@has_errors = false
    def cron(expr)
      parts = expr.split(" ")
      # https://github.com/sidekiq-scheduler/sidekiq-scheduler
      # Sidekiq scheduler has 6 fields. The first is for seconds. Cron does not support seconds.
      # We'll remove the seconds first field.
      if parts.size == 6
        parts.shift
      end
      if parts.size != 5
        log.info "ERROR: Unsupported cron expression. Too many fields."
        log.info "There are #{parts.size} fields. Should have exactly 5 fields"
        log.info "Offending cron expr: #{expr}"
        @@has_errors = true
      end
      # AWS Cron expressions require ? for the day of the week field
      parts[-1] = "?" if parts[-1] == "*"
      if parts.size == 5
        # AWS Cron expressions require a 6th year field
        parts << "*"
      end
      parts.join(" ")
    end

    def handle_every_expression!(result, expr)
      if simple_every?(expr)
        result[:rate] = rate_expression(expr)
      else
        # complex every expression translate to cron
        expr = Fugit::Nat.parse("every #{expr}").to_cron_s
        result[:cron] = cron(expr)
      end
    end

    def simple_every?(expr)
      # IE: 1h, 1d, 1w, 1m, 45m, 45 minutes, 1 hour, 1 day, 1 week, 1 month
      expr =~ /\d+\s?\w+/
    end

    def unsupported_fields!(result, original)
      unsupported = original.keys - SUPPORTED_FIELDS
      unsupported.each do |field|
        result[:"unsupported_#{field}"] = original[field]
      end
      result
    end

    def check_exist!
      unless File.exist?("config/sidekiq.yml")
        abort "ERROR: config/sidekiq.yml does not exist. Unable to translate".color(:red)
      end
    end

    def are_you_sure?
      message = <<~EOL
        This script will make changes to your project source code.

        It will try to translate the schedule items in

            config/sidekiq.yml => config/jets/schedule.yml

        Note: It's unfeasible to account for all cases perform miracle translations.
        It's a best-effort script, and the hope is that this script gets you pretty far
        and is helpful. 😄

        Please make sure you have backed up and committed your changes first.
      EOL
      sure?(message)
    end

    def finish_message
      # Created message part of finish message because only want it to show as part of CLI run
      log.info "\n    Created: config/jets/schedule.yml\n".color(:green)
      log.info <<~EOL
        Translation complete! Please double check the schedule to make sure it looks correct.
        Remember, this is a best-effort tool. It does not cover all cases.

        You can validate the config/jets/schedule.yml

            jets schedule:validate

        If that looks good, try deploying the config/jets/schedule.yml
        It should create a *JetsScheduledEvent* child stack
        with the schedule event rules.

            jets deploy
      EOL
    end
  end
end
