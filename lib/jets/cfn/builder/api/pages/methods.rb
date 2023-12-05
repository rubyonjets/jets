module Jets::Cfn::Builder::Api::Pages
  class Methods < Base
    class << self
      # interface method
      def uids
        if Jets.config.cfn.build.routes == "one_apigw_method_for_all_routes"
          return ['ANY|/', 'ANY|/*catchall']
        end

        routes = Jets::Router.routes
        routes.map do |route|
          "#{route.http_method}|#{route.path}"  # IE: GET|posts/:id
        end
      end
    end
  end
end
