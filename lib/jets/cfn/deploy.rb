module Jets::Cfn
  class Deploy < Stack
    def sync
      delete_rollback_complete!
      continue_update_rollback!
      check_deployable!

      log.debug "Parent template changed: #{changed?.inspect}"
      # return true when no changes so deploy will continue and start remote runner
      return true unless changed?

      # bootstrap can be "delete" or true
      # Set quiet before stack exists check
      quiet_sync = @options[:bootstrap] == true && stack_exists?(stack_name)
      deploy_message
      set_resource_tags
      begin
        sync_stack
      rescue Aws::CloudFormation::Errors::InsufficientCapabilitiesException => e
        capabilities = e.message.match(/\[(.*)\]/)[1]
        confirm = prompt_for_iam(capabilities)
        if /^y/.match?(confirm)
          @options.merge!(capabilities: [capabilities])
          log.info "Re-running: #{command_with_iam(capabilities).color(:green)}"
          retry
        else
          log.error "ERROR: Unable to deploy #{e.message}"
          exit 1
        end
      end

      # waits for /(_COMPLETE|_FAILED)$/ status to see if successfully deployed
      success = cfn_status.wait(quiet: quiet_sync)
      if success
        log.info "Bootstrap synced" if @options[:bootstrap] == true # dont use quiet_sync
      else
        if quiet_sync # show full cfn stack status if quiet_sync
          cfn_status.run
        end
        cfn_status.failure_message
      end
      success
    end

    # note: required method: rollback.rb module uses
    def cfn_status
      Jets::Cfn::Status.new
    end
    memoize :cfn_status

    # CloudFormation always performs an update there are nested templates, even when the
    # parent template has not changed at all.
    # Note: Jets ressurects the template body with a slight difference
    #    !Ref S3Bucket vs {Ref: S3Bucket}
    # However, tested with the exact template body without this difference
    # and cloudformation still performs an update.
    # So we have to check if the template has changed ourselves.
    # This is useful for the bootstrap genesis update.
    def changed?
      return true if @options[:force_changed]
      return true unless stack_exists?(stack_name)

      template_body = cfn.get_template(stack_name: stack_name).template_body
      existing = Yamler.load(template_body)
      fresh = Yamler.load(template.body)

      FileUtils.mkdir_p("#{Jets.build_root}/cfn/diff")
      IO.write("#{Jets.build_root}/cfn/diff/existing.yml", YAML.dump(existing))
      IO.write("#{Jets.build_root}/cfn/diff/fresh.yml", YAML.dump(fresh))

      existing != fresh
    end
    memoize :changed?

    def deploy_message
      if @options[:bootstrap_message]
        log.info "#{@options[:bootstrap_message]}: #{stack_name}"
      elsif @options[:bootstrap]
        log.info "Syncing bootstrap: #{stack_name}"
      else
        log.info "Deploying app: #{stack_name}"
      end
    end

    def set_resource_tags
      @tags = Jets.bootstrap.config.cfn.resource_tags.map { |k, v| {key: k, value: v} }
    end

    def sync_stack
      if stack_exists?(stack_name)
        update_stack
      else
        create_stack
      end
    end

    def create_stack
      # initial create stack template is on filesystem
      cfn.create_stack(stack_options)
    end

    def update_stack
      cfn.update_stack(stack_options)
    rescue Aws::CloudFormation::Errors::ValidationError => e
      log.debug "DEBUG bootstrap/deploy.rb update_stack #{e.message}" # ERROR: No updates are to be performed.
      true
    end

    # options common to both create_stack and update_stack
    def stack_options
      {
        stack_name: stack_name,
        capabilities: capabilities,
        tags: @tags
      }.merge(template.template_option)
    end

    def template
      Template.new(@options)
    end
    memoize :template

    # All CloudFormation states listed here:
    # http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-describing-stacks.html
    def stack_status
      resp = cfn.describe_stacks(stack_name: stack_name)
      status = resp.stacks[0].stack_status
      [resp, status]
    end

    def prompt_for_iam(capabilities)
      log.info "This stack will create IAM resources.  Please approve to run the command again with #{capabilities} capabilities."
      log.info "  #{command_with_iam(capabilities)}"

      log.info "Please confirm (y/n)"
      $stdin.gets # confirm
    end

    def command_with_iam(capabilities)
      "#{File.basename($0)} #{ARGV.join(" ")} --capabilities #{capabilities}"
    end

    def capabilities
      ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM"]
    end

    def stack_name
      Jets::Names.parent_stack_name
    end
  end
end
