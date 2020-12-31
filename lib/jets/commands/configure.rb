module Jets::Commands
  class Configure
    extend Memoist

    def initialize(options)
      @options = options
    end

    def run
      data = load_yaml
      data['key'] = token
      FileUtils.mkdir_p(File.dirname(path))
      IO.write(path, YAML.dump(data))
      puts "Updated #{pretty(path)}"
    end

    def load_yaml
      if File.exist?(path)
        YAML.load_file(path)
      else
        {}
      end
    rescue Psych::SyntaxError => e
      puts "WARN: There was an error reading #{pretty(path)}".color(:yellow)
      puts "WARN: #{e.class} #{e.message}".color(:yellow)
      {}
    end

    def pretty(path)
      path.sub(ENV['HOME'], '~')
    end

    def path
      "#{ENV['HOME']}/.jets/config.yml"
    end

    def token
      @options[:token] || prompt
    end
    memoize :token

    def prompt
      puts <<~EOL
        You are about to configure your ~/.jets/config.yml
        You can get a token from serverlessgems.com
      EOL
      print "Please provide your token: "
      $stdin.gets.strip
    end
  end
end
