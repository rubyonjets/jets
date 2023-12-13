module Jets::Thor
  # Not naming Options to avoid conflict with Thor::Options
  module SharedOptions
    extend ActiveSupport::Concern
    module ClassMethods
      def paging_options(defaults = {})
        option :limit, default: defaults[:limit] || 25, aliases: :l, type: :numeric, desc: "Per page limit"
        option :order, default: defaults[:order] || "asc", aliases: :o, desc: "Order: asc or desc"
        option :page, aliases: :p, type: :numeric, desc: "Page number"
      end

      def yes_option
        option :yes, aliases: :y, type: :boolean, desc: "Skip are you sure prompt"
      end

      def format_option(defaults = {})
        default = defaults[:default] || "table"
        option :format, default: default, desc: "Output format: #{CliFormat.formats.join(", ")}"
      end

      def verbose_option
        option :verbose, aliases: :v, default: false, type: :boolean, desc: "Show more verbose logging output. Useful for debugging what's under the hood"
      end

      def function_name_option(defaults = {})
        default = defaults[:default] || "controller"
        option :function, aliases: :n, default: default, desc: "Lambda Function name"
      end
    end
  end
end
