module Jets::Cfn::Builder::Api::Pages
  class Resources < Base
    class << self
      # interface method
      def uids
        if Jets.config.cfn.build.routes == "one_apigw_method_for_all_routes"
          return ['/', '/*catchall']
        end

        # Note: Do not use
        #     Jets::Router.routes.map(&:path)
        # It does not include all the top of the leaves.  Example:
        #   admin is not included
        #   admin/new is included
        # Also, do not include the root/homepage path. It's already created
        # in api-gateway.yml
        Jets::Router.all_paths.reject { |p| p.blank? }
      end
    end
  end
end
