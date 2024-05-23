require "singleton"

module Jets::Api
  class Config
    include Singleton
    extend Memoist

    def initialize(options = {})
      @options = options
      @config_path = "#{ENV["HOME"]}/.jets/config.yml"
    end

    def api_key
      ENV["JETS_API_KEY"] || data["api_key"] || data["key"] # keep key for backwards compatibility
    end

    def api_key?
      !!api_key
    end

    def clear_api_key
      FileUtils.rm_f(@config_path)
      puts "Removed #{@config_path.sub(ENV["HOME"], "~")}"
    end

    def data
      @data ||= load
    end

    # Ensure a Hash is returned
    def load
      return {} unless File.exist?(@config_path)

      data = YAML.load_file(@config_path)
      if data.is_a?(Hash)
        data
      else
        puts "WARN: #{@config_path} is not in the correct format. Loading an empty hash.".color(:yellow)
        {}
      end
    end

    def prompt
      puts <<~EOL
        You are about to configure your #{pretty_path(@config_path)}
        You can get an api key from www.rubyonjets.com
      EOL
      print "Please provide your api key: "
      $stdin.gets.strip
    end

    # interface method: do not remove
    def update_api_key(api_key = nil)
      api_key ||= prompt
      write(
        key: api_key,     # legacy jets 5 and below
        api_key: api_key  # legacy jets 6 and above
      ) # specify keys to allow
    end

    def write(values = {})
      data = load
      data.merge!(values.deep_stringify_keys)
      FileUtils.mkdir_p(File.dirname(@config_path))
      IO.write(@config_path, YAML.dump(data))
      puts "Updated #{pretty_path(@config_path)}"
    end

    def pretty_path(path)
      path.sub(ENV["HOME"], "~")
    end
  end
end
