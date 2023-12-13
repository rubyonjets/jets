require "aws-sdk-cloudwatchevents"

class Jets::CLI::Schedule
  class Validate < Base
    def run
      are_you_sure?
      check_exist!
      valid = perform
      if valid
        log.info "Validation passed. config/jets/schedule.yml is valid"
        if File.exist?("config/sidekiq.yml")
          log.info <<~EOL
            You can remove config/sidekiq.yml now. It is no longer needed.

                rm config/sidekiq.yml
          EOL
        end
      else
        log.info "Validation failed.  Please fix the errors and try again."
        log.info "Docs: https://docs.rubyonjets.com/docs/jobs/schedule/"
        exit 1
      end
    end

    # interface method: used by deploy to translate on_deploy
    def perform
      items = YAML.load_file("config/jets/schedule.yml")
      items = ActiveSupport::HashWithIndifferentAccess.new(items)
      items.each do |key, value|
        validate_item(key, value)
      end
      !@@has_errors
    end

    def check_exist!
      unless File.exist?("config/jets/schedule.yml")
        abort "config/jets/schedule.yml does not exist. Nothing to validate."
      end
    end

    @@rule_name = "validation_rule_#{Time.now.to_i}_#{rand(1000)}"
    @@has_errors = false
    def validate_item(key, value)
      log.debug "To validate, creating live event rule for #{key}"
      log.debug "value: #{value.inspect}"
      schedule_expression = if value[:cron]
        "cron(#{value[:cron]})"
      elsif value[:rate]
        expr = rate_expression(value[:rate])
        "rate(#{expr})"
      else
        raise "No schedule expression found for: #{key}"
      end

      # Create the rule with the provided cron expression
      client.put_rule(
        name: @@rule_name,
        schedule_expression: schedule_expression,
        state: "DISABLED" # Disable the rule to prevent it from being triggered
      )

      # log.info "Valid rule: #{key}"
      # log.info "  Schedule expression: #{schedule_expression}"
      true # If no error is raised, the cron expression is valid
    rescue Aws::CloudWatchEvents::Errors::ValidationException => e
      log.error "Invalid rule: #{key}"
      log.error "Schedule expression: #{schedule_expression}"
      # log.error "Validation Error: #{e.message}" # commented out to reduce noise, not useful
      @@has_errors ||= true
      false # If ValidationException is raised, the cron expression is invalid
    ensure
      # Delete the rule after validation (whether it's valid or not)
      begin
        client.delete_rule(name: @@rule_name)
      rescue
        nil
      end
    end

    def are_you_sure?
      message = <<~EOL
        Will validate: config/jets/schedule.yml

        It does this by creating a live test event rule for each entry in schedule.yml
        and then deleting it.
      EOL
      sure?(message)
    end

    def client
      Aws::CloudWatchEvents::Client.new
    end
    memoize :client
  end
end
