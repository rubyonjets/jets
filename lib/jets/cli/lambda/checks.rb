module Jets::CLI::Lambda
  module Checks
    extend Memoist

    def check_deployed!
      return if stack_exists?(Jets.project.namespace)
      warn "ERROR: Project has not been deployed".color(:red)
      exit 1
    end

    def check_workers!
      return if workers_deployed?
      warn "No worker functions deployed"
      exit 1
    end

    def workers_deployed?
      Jets::CLI::Maintenance::Worker::Saver.new(@options).lambda_functions.size > 0
    end
    memoize :workers_deployed?
  end
end
