class Jets::Resource::ApiGateway::RestApi::Routes::Change
  class Page < Base
    def changed?
      route_page_moved? || old_api_template?
    end

    def route_page_moved?
      moved?(new_pages, deployed_pages)
    end

    # Routes page to logical ids
    def moved?(new_pages, deployed_pages)
      not_moved = true # page has not moved
      new_pages.each do |logical_id, new_page_number|
        if !deployed_pages[logical_id].nil? && deployed_pages[logical_id] != new_page_number
          not_moved = false # page has moved
          break
        end
      end
      !not_moved # moved
    end

    def new_pages
      local_logical_ids_map
    end
    memoize :new_pages

    def deployed_pages
      remote_logical_ids_map
    end
    memoize :deployed_pages

    # logical id to page map
    # Important: In Cfn::Builders::ApiGatewayBuilder, the add_gateway_routes and ApiResourcesBuilder needs to run
    # before the parent add_gateway_rest_api method.
    def local_logical_ids_map(path_expression="#{Jets::Naming.template_path_prefix}-api-resources-*.yml")
      logical_ids = {} # logical id => page number

      Dir.glob(path_expression).each do |path|
        md = path.match(/-api-resources-(\d+).yml/)
        page_number = md[1]

        template = Jets::Cfn::BuiltTemplate.get(path)
        template['Resources'].keys.each do |logical_id|
          logical_ids[logical_id] = page_number
        end
      end

      logical_ids
    end

    # aws cloudformation describe-stack-resources --stack-name demo-dev-ApiResources1-DYGLIEY3VAWT | jq -r '.StackResources[].LogicalResourceId'
    def remote_logical_ids_map
      logical_ids = {} # logical id => page number

      parent_resources.each do |resource|
        stack_name = resource.physical_resource_id # full physical id can be used as stack name also
        regexp = Regexp.new("#{Jets.config.project_namespace}-ApiResources(\\d+)-") # tricky to escape \d pattern
        md = stack_name.match(regexp)
        if md
          page_number = md[1]

          resp = cfn.describe_stack_resources(stack_name: stack_name)
          resp.stack_resources.map(&:logical_resource_id).each do |logical_id|
            logical_ids[logical_id] = page_number
          end
        end
      end

      logical_ids
    end

    def old_api_template?
      logical_resource_ids = parent_resources.map(&:logical_resource_id)

      api_gateway_found = logical_resource_ids.detect do |logical_id|
        logical_id == "ApiGateway"
      end
      return false unless api_gateway_found

      api_resources_found = logical_resource_ids.detect do |logical_id|
        logical_id.match(/^ApiResources\d+$/)
      end
      !api_resources_found # if api_resources_found then it's the new structure. so opposite is old structure
    end

    def parent_resources
      resp = cfn.describe_stack_resources(stack_name: Jets::Naming.parent_stack_name)
      resp.stack_resources
    end
    memoize :parent_resources
  end
end
