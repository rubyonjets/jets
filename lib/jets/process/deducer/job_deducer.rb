# Deduces the path and method from the handler. Example:
#
#   deducer = JobDeducer.new("handlers/jobs/sleep.perform")
#   deducer.path # "./app/job/sleep_job.rb"
#   deducer.code # SleepJob.new(event, context).perform
#
# You can then use the deduction to require and run the code like so:
#
#   require "./app/job/sleep_job.rb"
#   result = SleepJob.new(event, context).perform
#
class Jets::Process::Deducer
  class JobDeducer < BaseDeducer
    def path
      path = Jets.root + @handler_path.sub("handlers", "app") + "_job.rb"
    end

    def application_path
      "#{Jets.root}app/jobs/application_job"
    end

    def code
      job_name = @handler_path.sub(%r{.*handlers/jobs/}, "") + "_job" # sleep_job
      job_class = job_name.camelize # SleepJob
      code = "#{job_class}.new(event, context).#{@handler_method}" # SleepJob.new(event, context).create
    end
  end
end