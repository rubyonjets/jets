class Jets::CLI::Ps
  class Errors < Jets::CLI::Ps
    extend Memoist

    def initialize(options = {})
      super
      @tasks = options[:tasks]
    end

    def show
      message = recent_message
      return unless message
      return if /has reached a steady state/.match?(message)

      scale
      target_group
      deployment_configuration
      wrong_vpc
      catchall
    end

    # If running count < desired account for a long time
    # And see was unable to place a task
    # Probably not enough capacity
    def scale
      return if ecs_service.running_count >= ecs_service.desired_count

      error_event = recent_events.find do |e|
        e.message =~ /was unable to place a task/
      end
      return unless error_event

      logger.info "There is an issue scaling the #{ecs_service.service_name} to #{ecs_service.desired_count}.  Here's the error:"
      logger.info error_event.message.color(:red)
      if ecs_service.launch_type == "EC2"
        logger.info <<~EOL
          If AutoScaling is set up for the container instances,
          it can take a little time to add additional instances.
          You'll see this message until the capacity is added.
        EOL
      end
    end

    # The error currently happens to be the 5th element.
    #
    # Example:
    #     (service XXX) (instance i-XXX) (port 32875) is unhealthy in (target-group arn:aws:elasticloadbalancing:us-east-1:111111111111:targetgroup/devel-Targe-1111111111111/1111111111111111) due to (reason Health checks failed with these codes: [400])">]
    def target_group
      error_event = recent_events.find do |e|
        e.message =~ /is unhealthy in/ &&
          e.message =~ /targetgroup/
      end
      return unless error_event

      logger.error "There are targets in the target group reporting unhealthy.  This can cause containers to cycle. Here's the error:"
      logger.error error_event.message.color(:red)
      logger.error <<~EOL
        Check out the ECS console and EC2 Load Balancer console for more info.
        Sometimes they may not helpful :(
        Docs that may help: https://rubyonjets.com/docs/debug/unhealthy-targets/
      EOL
    end

    # To reproduce
    #
    # .ufo/config.rb
    #
    #     Ufo.configure do |config|
    #       config.ecs.maximum_percent = 150 # need at least 200 to go from 1 to 2 containers
    #       config.ecs.minimum_healthy_percent = 100
    #     end
    #
    # Event message error:
    #
    #     ERROR: (service app1-web-dev-EcsService-8FMliG8m6M2p) was unable to stop or start tasks during a deployment because of the service deployment configuration. Update the minimumHealthyPercent or maximumPercent value and try again.
    #
    def deployment_configuration
      message = recent_message
      return unless message.include?("unable") && message.include?("deployment configuration")

      logger.error "ERROR: Deployment Configuration".color(:red)
      logger.error <<~EOL
        You might have a Deployment Configuration that prevents the deployment from completing.

        See: https://rubyonjets.com/docs/debug/deployment-configuration/

      EOL
    end

    # To reproduce #1
    #
    #   1. Deploy to with settings where ECS cluster is in custom VPC successfully
    #   2. Deploy again. Accidentally with default VPC settings <= Reproduction
    #
    # This will produce a CloudFormation stack failure
    #
    # > All subnets must belong to the same VPC: 'vpc-11111111' (Service: AmazonElasticLoadBalancing; Status Code: 400; Error Code: InvalidConfigurationRequest; Request ID: b8c683ca-4c6d-4bf9-bf9b-3eb468fa9ea9; Proxy: null)
    #
    # So it's not actually an ECS failure and is caught early on. Notiing it for posterity.
    #
    # To reproduce #2
    #
    #   Deploy to default VPC. Even though ECS cluster is running on a custom VPC <= Reproduction
    #
    # This reproduces:
    #
    # > ERROR: (service demo-web-dev-EcsService-RkMBAhHBfx9A) failed to register targets in (target-group arn:aws:elasticloadbalancing:us-west-2:111111111111:targetgroup/demo-Targe-1HEN2QPS5LO9B/0c69c3eb5aa23bc9) with (error The following targets are not in the target group VPC 'vpc-11111111': 'i-11111111111111111')
    #
    # The first deploy suceeeds because CloudFormation doesn't check on the ECS service as much here.
    # ECS does report the error though.
    #
    def wrong_vpc
      error_event = recent_events.find do |e|
        e.message =~ /targets are not in the target group VPC/ ||
          e.message =~ /All subnets must belong to the same VPC/
      end
      return unless error_event

      logger.info "ERROR: VPC Configuration error".color(:red)
      logger.info error_event.message.color(:red)
      logger.info <<~EOL
        It seems like the ECS Service was deployed to an ECS Cluster running on
        a different VPC than what's the ECS Service is configured with.

        See: https://rubyonjets.com/docs/debug/vpc-subnets/
      EOL
    end

    # Example:
    #     (service app1-web-dev-EcsService-8FMliG8m6M2p) was unable to stop or start tasks during a deployment because of the service deployment configuration. Update the minimumHealthyPercent or maximumPercent value and try again.
    def catchall
      words = %w[fail unable error]
      recent_messages = recent_events.map(&:message)
      message = recent_messages.find do |message|
        words.detect { |word| message.include?(word) }
      end

      return unless message
      logger.error "ERROR: #{message}".color(:red)

      logger.error <<~EOL
        You might have to cancel the stack with th CloudFormation console and
        try again after fixing the issue.
      EOL
    end

    private

    # only check a few most recent
    def recent_events
      ecs_service["events"][0..4]
    end

    def recent_message
      recent = recent_events.first
      return unless recent
      recent.message || nil
    end
  end
end
