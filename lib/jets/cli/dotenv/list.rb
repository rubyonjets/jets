require "shellwords"

class Jets::CLI::Dotenv
  class List < Base
    def run
      presenter = CliFormat::Presenter.new(@options)
      warn "# Env from config/jets/env files and SSM parameters"
      warn "# Values are not used locally. They are only used for the Lambda Function"
      unless @options[:reveal]
        warn "# To show values also, use the --reveal option"
      end
      presenter.empty_message = "# No env vars found"
      unless @options[:format] == "dotenv"
        header = ["Name"]
        header << "Value" if @options[:reveal]
        presenter.header = header
      end
      vars = Jets::Dotenv.parse
      vars.each do |key, value|
        v = inspect?(value) ? value.inspect : value
        row = [key]
        row << v if @options[:reveal]
        presenter.rows << row
      end
      presenter.show
    end

    def inspect?(value)
      value.include?("\n") || Shellwords.escape(value) != value
    end
  end
end
