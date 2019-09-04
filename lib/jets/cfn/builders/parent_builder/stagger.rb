class Jets::Cfn::Builders::ParentBuilder
  module Stagger
    def add_stagger(resource)
      batch_size = stagger_batch_size # shorter convenience variable
      return if !stagger_enabled || batch_size.nil? || batch_size == 0

      # initialize all here to keep logic together
      @previous_stacks ||= []
      @added_count ||= 0

      if @previous_stacks.size >= batch_size
        at_boundary = @added_count % batch_size == 0
        if at_boundary
          @left = @added_count - batch_size
          @right = @left + batch_size - 1
        end
        previous_stack_batch = @previous_stacks[@left..@right]
        resource.add_stagger_depends_on(previous_stack_batch)
      end

      @added_count += 1
      @previous_stacks << resource
    end

    def stagger_batch_size
      Jets.config.deploy.stagger.batch_size
    end

    # for spec-ing
    def stagger_enabled
      Jets.config.deploy.stagger.enabled
    end
  end
end
