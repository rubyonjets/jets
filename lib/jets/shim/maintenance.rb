module Jets::Shim
  class Maintenance
    class << self
      extend Memoist
      include Jets::Util::Truthy

      def app
        self
      end

      def call(env)
        [503, {"Content-Type" => content_type}, [body]]
      end

      # IE: application/json; charset=utf-8
      # IE: text/html
      def content_type
        maintenance_file.end_with?("json") ? "application/json" : "text/html"
      end

      def body
        IO.read(maintenance_file)
      end

      def maintenance_file
        default_path = "#{__dir__}/maintenance/maintenance.html"
        paths = %w[public/maintenance.html public/maintenance.json]
        paths.find { |path| File.exist?(path) } || default_path
      end
      memoize :maintenance_file

      def enabled?
        truthy?(ENV["JETS_MAINTENANCE"])
      end
    end
  end
end
