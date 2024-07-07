class Jets::CLI
  class Base
    extend Memoist
    include Jets::Api
    include Jets::AwsServices::AwsHelpers
    include Jets::Util::Logging
    include Jets::Util::Sure

    attr_reader :options
    def initialize(options = {})
      @options = options
      Jets.boot
    end

    def deploy_type
      parent_stack = find_stack(parent_stack_name)
      return unless parent_stack
      parent_stack.outputs.find do |o|
        case o.output_key
        when "Ecs"
          return "ecs"
        when "Controller"
          return "lambda"
        end
      end
    end
    memoize :deploy_type

    def paging_params
      params = {}
      params[:limit] = @options[:limit] if @options[:limit]
      params[:order] = @options[:order] if @options[:order]
      params[:page] = @options[:page] if @options[:page]
      params
    end

    def paginate(resp)
      return unless resp[:total_pages] > 1
      warn "\npage #{resp[:current_page]} of #{resp[:total_pages]}"
    end

    class << self
      def rescue_api_error(*methods)
        methods = [:run] if methods.empty?
        mod = Module.new do
          methods.each do |method_name|
            define_method(method_name) do |*args, &block|
              super(*args, &block)
            rescue Jets::Api::Error => e
              warn "Jets API Error. #{e.message}".color(:red)
              log.debug e.backtrace.join("\n")
              exit 1
            end
          end
        end
        prepend mod
      end
    end
  end
end
