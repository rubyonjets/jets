class Jets::Cfn
  class Status
    include Jets::AwsServices

    attr_reader :events
    def initialize(options={})
      @options = options
      @stack_name = Jets::Naming.parent_stack_name
      reset
    end

    # used for the jets status command
    def run
      unless stack_exists?(@stack_name)
        puts "The stack #{@stack_name.colorize(:green)} does not exist."
        return
      end

      resp = cfn.describe_stacks(stack_name: @stack_name)
      stack = resp.stacks.first

      puts "The current status for the stack #{@stack_name.colorize(:green)} is #{stack.stack_status.colorize(:green)}"
      if stack.stack_status =~ /_IN_PROGRESS$/
        puts "Stack events (tailing):"
        # tail all events until done
        @hide_time_took = true
        wait
      else
        puts "Stack events:"
        # show the last events that was user initiated
        refresh_events
        show_events(true)
      end
    end

    def reset
      @events = [] # constantly replaced with recent events
      @last_shown_event_id = nil
      @stack_deletion_completed = nil
    end

    # check for /(_COMPLETE|_FAILED)$/ status
    def wait
      start_time = Time.now

      refresh_events
      until completed || @stack_deletion_completed
        show_events
      end
      show_events(true) # show the final event

      if @stack_deletion_completed
        puts "Stack #{@stack_name} deleted."
        return
      end

      if last_event_status =~ /_FAILED/
        puts "Stack failed: #{last_event_status}".colorize(:red)
        puts "Stack reason #{@events[0]["resource_status_reason"]}".colorize(:red)
      elsif last_event_status =~ /_ROLLBACK_/
        puts "Stack rolled back: #{last_event_status}".colorize(:red)
      else # success
        puts "Stack success status: #{last_event_status}".colorize(:green)
      end

      # Never gets here when deleting a stack because the describe stack returns nothing
      # once the stack is deleted. Gets here for stack create and update though.
      return if @hide_time_took # set in run
      took = Time.now - start_time
      puts "Time took for stack deployment: #{pretty_time(took).green}."
    end

    def completed
      last_event_status =~ /(_COMPLETE|_FAILED)$/ &&
      @events[0]["logical_resource_id"] == @stack_name &&
      @events[0]["resource_type"] == "AWS::CloudFormation::Stack"
    end

    def last_event_status
      @events[0]["resource_status"]
    end

    # Only shows new events
    def show_events(final=false)
      if @last_shown_event_id.nil?
        i = find_index(:start)
        print_events(i)
      else
        i = find_index(:last_shown)
        # puts "last_shown index #{i}"
        print_events(i-1) unless i == 0
      end

      return if final
      sleep 5 unless ENV['TEST']
      refresh_events
    end

    def print_events(i)
      @events[0..i].reverse.each do |e|
        print_event(e)
      end
      @last_shown_event_id = @events[0]["event_id"]
      # puts "@last_shown_event_id #{@last_shown_event_id.inspect}"
    end

    def print_event(e)
      message = [
        event_time(e["timestamp"]),
        e["resource_status"],
        e["resource_type"],
        e["logical_resource_id"],
        e["resource_status_reason"]
      ].join(" ")
      message = message.colorize(:red) if e["resource_status"] =~ /_FAILED/
      puts message
    end

    # https://stackoverflow.com/questions/18000432/rails-12-hour-am-pm-range-for-a-day
    def event_time(timestamp)
      Time.parse(timestamp.to_s).localtime.strftime("%I:%M:%S%p")
    end

    # refreshes the loaded events in memory
    def refresh_events
      resp = cfn.describe_stack_events(stack_name: @stack_name)
      @events = resp["stack_events"]
    rescue Aws::CloudFormation::Errors::ValidationError => e
      if e.message =~ /Stack .* does not exis/
        @stack_deletion_completed = true
      else
        raise
      end
    end

    def find_index(name)
      send("#{name}_index")
    end

    def start_index
      @events.find_index do |event|
        event["resource_type"] == "AWS::CloudFormation::Stack" &&
        event["resource_status_reason"] == "User Initiated"
      end
    end

    def last_shown_index
      @events.find_index do |event|
        event["event_id"] == @last_shown_event_id
      end
    end

    def success?
      resource_status = @events[0]["resource_status"]
      %w[CREATE_COMPLETE UPDATE_COMPLETE].include?(resource_status)
    end

    def update_rollback?
      @events[0]["resource_status"] == "UPDATE_ROLLBACK_COMPLETE"
    end

    def find_update_failed_event
      i = @events.find_index do |event|
        event["resource_type"] == "AWS::CloudFormation::Stack" &&
        event["resource_status_reason"] == "User Initiated"
      end

      @events[0..i].reverse.find do |e|
        e["resource_status"] == "UPDATE_FAILED"
      end
    end

    def rollback_error_message
      return unless update_rollback?

      event = find_update_failed_event
      return unless event

      reason = event["resource_status_reason"]
      messages_map.each do |pattern, message|
        if reason =~ pattern
          return message
        end
      end

      reason # default message is original reason if not found in messages map
    end

    def messages_map
      {
        /CloudFormation cannot update a stack when a custom-named resource requires replacing/ => "A workaround is to run ufo again with STATIC_NAME=0 and to switch to dynamic names for resources. Then run ufo again with STATIC_NAME=1 to get back to statically name resources. Note, there are caveats with the workaround.",
        /cannot be associated with more than one load balancer/ => "There's was an issue updating the stack. Target groups can only be associated with one load balancer at a time. The workaround for this is to use UFO_FORCE_TARGET_GROUP=1 and run the command again. This will force the recreation of the target group resource.",
        /SetSubnets is not supported for load balancers of type/ => "Changing subnets for Network Load Balancers is currently not supported. You can try workarouding this with UFO_FORCE_ELB=1 and run the command again. This will force the recreation of the elb resource."
      }
    end

    # http://stackoverflow.com/questions/4175733/convert-duration-to-hoursminutesseconds-or-similar-in-rails-3-or-ruby
    def pretty_time(total_seconds)
      minutes = (total_seconds / 60) % 60
      seconds = total_seconds % 60
      if total_seconds < 60
        "#{seconds.to_i}s"
      else
        "#{minutes.to_i}m #{seconds.to_i}s"
      end
    end
  end
end
