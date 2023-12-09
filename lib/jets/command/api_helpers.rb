module Jets
  module Command
    module ApiHelpers # :nodoc:
      extend ActiveSupport::Concern

      include Jets::Api

      def no_token_exit!
        return if Jets::Api.token
        puts "ERROR: This command requires Jets Api".color(:red)
        puts "Please run `jets configure` first"
        exit 1
      end

      def check_for_error_message!(resp)
        # IE: {"error":"Invalid token. Please check your token in ~/.jets/config.yml"}
        if resp && resp["error"]
          $stderr.puts "ERROR: #{resp["error"]}"
          exit 1
        end
        resp
      end

      def paging_params
        Jets.boot
        params = {}
        params[:page] = @options[:page] if @options[:page]
        params[:order] = @options[:order] if @options[:order]
        params
      end

      module ClassMethods
        def paging_options(defaults={})
          Proc.new do
            option :page, aliases: :p, type: :numeric, desc: "Page number"
            option :order, default: defaults[:order] || 'asc', desc: "Order: asc or desc"
          end
        end
      end
    end
  end
end
