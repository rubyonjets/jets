module Jets # :nodoc:
  class Generators # :nodoc:
    class JobGenerator < Rails::Generators::NamedBase # :nodoc:
      desc "This generator creates an Jets job file at app/jobs"

      class_option :name, aliases: :n, default: "perform", desc: "The method name for job"
      class_option :type, aliases: :t, default: "scheduled", desc: "The job event type: dynamodb iot kinesis log rule s3 scheduled sns sqs"

      def self.default_generator_root
        __dir__
      end

      def self.banner
        "jets generate job #{self.arguments.map(&:usage).join(' ')} [options]"
      end

      def create_job_file
        template "event_types/#{options[:type]}.rb", File.join("app/jobs", class_path, "#{file_name}_job.rb")

        in_root do
          if behavior == :invoke && !File.exist?(application_job_file_name)
            template "application_job.rb", application_job_file_name
          end
        end
      end

      private
        def file_name
          @_file_name ||= super.sub(/_job\z/i, "")
        end

        def application_job_file_name
          @application_job_file_name ||= if mountable_engine?
            "app/jobs/#{namespaced_path}/application_job.rb"
          else
            "app/jobs/application_job.rb"
          end
        end
    end
  end
end
