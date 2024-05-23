module Jets::Shim::Adapter
  class Alb < Apigw
    def env
      super.merge(
        "HTTP_PORT" => headers["x-forwarded-port"],
        "SERVER_PORT" => headers["x-forwarded-port"],
        "SERVER_PROTOCOL" => event.dig("requestContext", "protocol") || "HTTP/1.1"
      )
    end

    def handle?
      host =~ /elb\.amazonaws\.com/ ||
        event.dig("requestContext", "elb")
    end
  end
end
