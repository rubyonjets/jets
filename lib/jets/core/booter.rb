require "securerandom"

module Jets::Core
  class Booter
    class << self
      extend Memoist

      attr_reader :boot_at, :gid
      def boot!
        return false if @boot_at

        Jets::Bundle.require # require all the gems in the Gemfile
        require_config(:project) # for config.dotenv.overwrite

        if require_bootstrap?
          Jets::Dotenv.load!
          require_config(:bootstrap)
        end

        initialize!

        @gid = SecureRandom.uuid[0..7]
        @boot_at = Time.now.utc
      end

      def initialize!
        main = Jets::Autoloaders.main
        main.configure(Jets.root)
        main.setup
      end

      # Essentially deployment commands require the bootstrap to be run
      def require_bootstrap?
        args = ARGV.reject { |arg| arg.start_with?("-") }
        %w[
          bootstrap
          build
          delete
          deploy
          dockerfile
          release:rollback
        ].include?(args.last)
      end

      def require_config(name)
        files = [
          "config/jets/#{name}.rb",
          "config/jets/#{name}/#{Jets.env}.rb"
        ]
        files.each do |file|
          next unless File.exist?(file)
          require "#{Jets.root}/#{file}"
        end
      end
      memoize :require_config
    end
  end
end
