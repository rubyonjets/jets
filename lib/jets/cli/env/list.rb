class Jets::CLI::Env
  class List < Base
    def run
      warn "# Env Variables for #{Jets.project.namespace}"
      unless @options[:reveal]
        warn "# To show values also, use the --reveal option"
      end
      vars = @lambda_function.environment_variables

      presenter = CliFormat::Presenter.new(@options)
      vars.each do |key, value|
        row = [key]
        row << value if @options[:reveal]
        presenter.rows << row
      end
      presenter.show
    end
  end
end
