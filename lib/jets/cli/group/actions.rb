module Jets::CLI::Group
  module Actions
    extend Memoist

    def config_environment(data, options = {})
      config_file = if options[:env]
        "config/environments/#{options[:env]}.rb"
      else
        "config/application.rb"
      end
      lines = IO.readlines(config_file)
      # remove comment lines
      lines.reject! { |line| line =~ /^\s*#/ }
      found = lines.any? { |line| line.include?(data) }
      environment(data, options) unless found
    end

    def environment(data = nil, options = {})
      sentinel = "class Application < Rails::Application\n"
      env_file_sentinel = "Rails.application.configure do\n"
      data ||= yield if block_given?

      in_root do
        if options[:env].nil?
          inject_into_file "config/application.rb", optimize_indentation(data, 4), after: sentinel, verbose: true
        else
          Array(options[:env]).each do |env|
            inject_into_file "config/environments/#{env}.rb", optimize_indentation(data, 2), after: env_file_sentinel, verbose: true
          end
        end
      end
    end
    alias_method :application, :environment

    def optimize_indentation(value, amount = 0) # :doc:
      return "#{value}\n" unless value.is_a?(String)
      "#{value.strip_heredoc.indent(amount).chomp}\n"
    end
    alias_method :rebase_indentation, :optimize_indentation

    def comment_out_line(string, options = {})
      file = if options[:env]
        "config/environments/#{options[:env]}.rb"
      else
        "config/application.rb"
      end
      lines = IO.readlines(file).map do |l|
        if l.include?(string) && !l.strip.start_with?("#")
          "  # #{l.strip}"
        else
          l
        end
      end
      IO.write(file, lines.join)
    end
  end
end
