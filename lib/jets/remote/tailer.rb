require "aws-logs"

module Jets::Remote
  class Tailer < Base
    include Jets::Util::Pretty

    def initialize(options, build_id)
      @options, @build_id = options, build_id

      @output = [] # for specs
      @shown_phases = []
      @thread = nil
    end

    @@delay = 2 # initial delay
    def run
      complete = false
      until complete
        build = find_build
        unless build
          puts "ERROR: Build id not found: #{@build_id}".color(:red)
          return
        end

        # CodeBuild AWS Lambda Compute Type take slightly a few milliseconds to report phases.
        # But return the build already. So we have to wait until the phases are available.
        while build.phases.nil?
          build = find_build # refresh
          sleep 1
        end

        print_phases(build) unless @stop_printing_phases # once cloudwatch logs starts, stop printing phases
        set_log_group_name(build)

        complete = build.build_complete

        next if ENV["JETS_TEST"]
        if build_phase_started?(build)
          start_cloudwatch_tail
          @stop_printing_phases = true
          @@delay = 5 # increase @@delay also
        end

        sleep @@delay
      end

      stop_cloudwatch_tail(build)
      if Jets.bootstrap.config.codebuild.logging.final_phases
        print_phases(build) # print final phases
      end
      display_failed_phases(build)
    end

    def build_phase_started?(build)
      @build_phase_started ||= build.phases.any? do |phase|
        phase.phase_type == "BUILD"
      end
    end

    def display_failed_phases(build)
      status = build.build_status.to_s # in case nil
      status = (status != "SUCCEEDED") ? status.color(:red) : status.color(:green)
      return if status == "SUCCEEDED"

      failed_phases = build.phases.select do |phase|
        phase.phase_status != "SUCCEEDED" && phase.phase_status.to_s != ""
      end
      return if failed_phases.empty?

      puts "Failed Phases:"
      failed_phases.each do |phase|
        puts "#{phase.phase_type}: #{phase.phase_status.color(:red)}"
        next unless phase.contexts # can be nil
        context = phase.contexts.last
        if context # show error details: Unable to pull customer's container image https://gist.github.com/tongueroo/22e4ca3d4cde002108ff506eba9062f6
          message = context.message
          puts message
          if message.include?("CannotPullContainerError") && message.include?("access denied")
            puts "See: https://docs.aws.amazon.com/codebuild/latest/userguide/sample-ecr.html"
          end
        end
      end
    end

    def display_time_took(build)
      puts "Remote runner took #{build_time(build)} to complete"
    end

    def find_build
      resp = codebuild.batch_get_builds(ids: [@build_id])
      resp.builds.first
    rescue Aws::CodeBuild::Errors::ThrottlingException => e
      log_arch "WARN: find_build codebuild.batch_get_builds ThrottlingException: #{e.message}"
      @@delay = 10 # increase global @@delay also

      # Also exponential backoff delay
      # 2, 4, 8, 16, 32
      @retries ||= 1
      raise if @retries > 5 # give up after 5 retries
      delay = 2**@retries
      log_arch "Retrying in #{delay}s..."
      sleep delay
      @retries += 1
      retry
    end

    def start_cloudwatch_tail
      return if @cloudwatch_tail_started
      return unless @log_group_name && @log_stream_name

      @thread = Thread.new do
        @cw_tail = cloudwatch_tail
        @cw_tail.run
      end
      @cloudwatch_tail_started = true
    end

    def cloudwatch_tail
      since = @options[:since] || "24h" # by default, search only 24h in the past
      AwsLogs::Tail.new(
        log_group_name: @log_group_name,
        log_stream_names: [@log_stream_name],
        since: since,
        follow: true,
        format: "plain",
        show_if: show_if
      )
    end

    def show_if
      return true unless Jets.bootstrap.config.codebuild.logging.show == "filtered"

      start_marker = "./jets"
      end_marker = "Phase complete: BUILD"
      proc do |event|
        @display_showing ||= event.message.include?(start_marker)
        if @display_showing && event.message.include?(end_marker)
          @display_showing = false
        end
        @display_showing
      end
    end
    memoize :show_if

    def stop_cloudwatch_tail(build)
      return if ENV["JETS_TEST"]
      @cw_tail&.stop_follow!
      @thread&.join
    end

    def logs_command?
      ARGV.join(" ").include?("logs")
    end

    # build.build_status : The current status of the build. Valid values include:
    #
    #     FAILED : The build failed.
    #     FAULT : The build faulted.
    #     IN_PROGRESS : The build is still in progress.
    #     STOPPED : The build stopped.
    #     SUCCEEDED : The build succeeded.
    #     TIMED_OUT : The build timed out.
    #
    def complete_failed?(build)
      return if ENV["JETS_TEST"]
      build.build_complete && build.build_status != "SUCCEEDED"
    end

    # Setting enables start_cloudwatch_tail
    def set_log_group_name(build)
      logs = build.logs
      @log_group_name = logs.group_name if logs.group_name
      @log_stream_name = logs.stream_name if logs.stream_name
    end

    def print_phases(build)
      build.phases.each do |phase|
        details = {
          phase_type: phase.phase_type,
          phase_status: phase.phase_status,
          start_time: phase.start_time,
          duration_in_seconds: phase.duration_in_seconds
        }
        display_phase(details)
        @shown_phases << details
      end
    end

    def display_phase(details)
      already_shown = @shown_phases.detect do |p|
        p[:phase_type] == details[:phase_type] &&
          p[:phase_status] == details[:phase_status] &&
          p[:start_time] == details[:start_time] &&
          p[:duration_in_seconds] == details[:duration_in_seconds]
      end
      return if already_shown

      return if filter_phase_type?(details)

      phases = [
        "Phase:", details[:phase_type]
      ]

      if details[:phase_type] == "COMPLETED"
        # nothing to add
      elsif details[:phase_status].nil?
        phases << "Pending"
      else
        phases += [
          phase_status(details[:phase_status]),
          phase_duration(details[:duration_in_seconds])
        ]
      end

      phases = phases.flatten.compact.join(" ")

      say phases
    end

    def filter_phase_type?(details)
      return false unless Jets.bootstrap.config.codebuild.logging.show == "filtered"

      # Phase: SUBMITTED Status: SUCCEEDED Duration: 0s
      # Phase: QUEUED Pending
      # Phase: QUEUED Status: SUCCEEDED Duration: 0s
      # Phase: PROVISIONING Pending
      # Phase: PROVISIONING Status: SUCCEEDED Duration: 5s
      # Phase: DOWNLOAD_SOURCE Status: SUCCEEDED Duration: 0s
      # Phase: INSTALL Status: SUCCEEDED Duration: 0s
      # Phase: PRE_BUILD Status: SUCCEEDED Duration: 0s
      # Phase: BUILD Pending
      # [Container] 2024/04/06 15:51:12.262049 Running command ...
      #
      # Becomes
      #
      # Phase: SUBMITTED Status: SUCCEEDED Duration: 0s
      # Phase: QUEUED Pending
      # Phase: QUEUED Status: SUCCEEDED Duration: 0s
      # Phase: PROVISIONING Pending
      # Phase: PROVISIONING Status: SUCCEEDED Duration: 5s
      # [Container] 2024/04/06 15:51:12.262049 Running command ...
      filtered_phase_types = %w[DOWNLOAD_SOURCE INSTALL PRE_BUILD BUILD]
      filtered_phase_types.include?(details[:phase_type])
    end

    def phase_status(status)
      return unless status # can be nil

      text = (status == "SUCCEEDED") ? status : status.color(:red)
      ["Status:", text]
    end

    def phase_duration(duration)
      return unless duration # can be nil

      ["Duration:", pretty_time(duration)]
    end

    def say(text)
      ENV["JETS_TEST"] ? @output << text : puts(text)
    end

    def output
      @output.join("\n") + "\n"
    end

    def build_time(build)
      duration = build.phases.inject(0) { |sum, p| sum + p.duration_in_seconds.to_i }
      pretty_time(duration)
    end
  end
end
