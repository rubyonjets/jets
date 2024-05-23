class Jets::CLI::Ci
  class Tailer < Jets::Remote::Tailer
    def show_if
      return true unless Jets.bootstrap.config.codebuild.logging.show == "filtered"

      start_marker = "Entering phase BUILD"
      end_marker = "Phase complete: BUILD"
      proc do |event|
        @display_showing ||= event.message.include?(start_marker)
        if @display_showing && event.message.include?(end_marker)
          @display_showing = false
        end
        @display_showing && !event.message.include?(start_marker)
      end
    end
  end
end
