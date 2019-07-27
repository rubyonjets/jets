class Jets::Controller
  class Stage
    def initialize(host, url)
      @host, @url = host, url
    end

    def add
      return @url unless add_stage?

      stage_name = Jets::Resource::ApiGateway::Deployment.stage_name
      stage_name_with_slashes = "/#{stage_name}/" # use to prevent stage name being added twice if url_for is called twice on the same string
      @url.include?(stage_name_with_slashes) ? @url : "/#{stage_name}#{@url}"
    end

    def add_stage?
      return false if on_cloud9?
      @host.include?("amazonaws.com") && @url.starts_with?('/')
    end

    def on_cloud9?
      self.class.on_cloud9?(@host)
    end

    class << self
      def add(host, url)
        new(host, url).add
      end

      def on_cloud9?(host)
        !!(host =~ /cloud9\..*\.amazonaws\.com/)
      end
    end
  end
end
