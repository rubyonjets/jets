module Jets::Cfn
  class Deployment
    extend Memoist
    include Jets::AwsServices
    include Jets::Command::AwsHelpers
    include Jets::Command::ApiHelpers

    def initialize(options={})
      @options = options
      @stack_name = options[:stack_name] # stack name or stack id (deleted)
      @rollback_version = options[:rollback_version]
    end

    def create
      Jets.boot # needed since Jets is lazy loaded
      return if Jets.config.pro.disable
      return unless Jets::Api.token
      stack = find_stack(@stack_name)
      return unless stack

      record_deployment(stack)
    end

    def record_deployment(stack)
      deploy_user = ENV['JETS_DEPLOY_USER'] || ENV['USER']
      resp = Jets::Api::Release.create(
        stack_arn: stack.stack_id,
        stack_status: stack.stack_status,
        message: message,
        deploy_user: deploy_user,
      )
      check_for_error_message!(resp)
      puts "Release version: #{resp["version"]}" if resp["version"]
      resp
    rescue Jets::Api::RequestError => e
      puts "WARNING: Unable to create release. #{e.class}: #{e.message}"
    end

    def message
      return @options[:message][0..255] if @options[:message]
      # else default message
      @rollback_version ? "Rollback to #{@rollback_version}" : "Deploy"
    end
  end
end
