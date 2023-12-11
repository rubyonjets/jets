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
      return if disabled?
      @stack = find_stack(@stack_name)
      record_deployment if @stack
    end

    def delete
      Jets.boot # needed since Jets is lazy loaded
      return if disabled?
      @stack = find_stack(@stack_name)
      delete_deployment if @stack
    end

    def delete_deployment
      resp = Jets::Api::Stack.retrieve("current")
      return if resp["error"] == "not_found"
      return unless resp["id"]
      resp = Jets::Api::Stack.delete(resp["id"])
      puts resp["message"] # IE: Stack demo-dev deleted
      resp
    rescue Jets::Api::RequestError => e
      puts "WARNING: Unable to delete release and stack. #{e.class}: #{e.message}"
    end

    def record_deployment
      params = stack_params.merge(git_info.params)
      params["message"] = create_message
      resp = Jets::Api::Release.create(params)
      # Instead of check_for_error_message!(resp) we want to customize it a bit
      if resp && resp["error"]
        $stderr.puts "WARN: There was an error creating the release."
        $stderr.puts "WARN: #{resp["error"]}"
        exit 1
      end
      puts "Release version: #{resp["version"]}" if resp["version"]
      resp
    rescue Jets::Api::RequestError => e
      puts "WARNING: Unable to create release. #{e.class}: #{e.message}"
    end

    def stack_params
      {
        stack_arn: @stack.stack_id,
        stack_status: @stack.stack_status,
        message: create_message,
        deploy_user: deploy_user,
      }
    end

    def deploy_user
      ENV['JETS_DEPLOY_USER'] || git_info.user.first_name || ENV['USER']
    end

    def git_info
      Jets::Git::Info.new(@options)
    end
    memoize :git_info

    def create_message
      if @options[:message]
        @options[:message][0..255]
      else
        @rollback_version ? "Rollback to #{@rollback_version}" : "Deploy"
      end
    end

    def disabled?
      Jets.config.pro.disable || !Jets::Api.token
    end
  end
end
