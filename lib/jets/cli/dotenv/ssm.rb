class Jets::CLI::Dotenv
  # The update logic is here and not a part of Jets::Dotenv::Ssm to emphasize
  # that it's only used for jets dotenv commands.
  # This class is responsible for updating.
  # The other Jets::Dotenv class is only repsonsible for reading.
  # The one part of the other class that is used is Jets::Dotenv::Convention
  class Ssm
    include Jets::AwsServices
    include Jets::Util::Logging

    def initialize(options = {})
      @options = options
      @parameter_type = options[:secure] ? "SecureString" : "String"
    end

    def set(params)
      # Loop through the hash and update each parameter
      params.each do |name, value|
        name = conventional_name(name)
        ssm.put_parameter(
          name: name,               # The name of the parameter
          value: value,             # The new value for the parameter
          type: @parameter_type,     # Set type to 'SecureString' if secure, else 'String'
          overwrite: true           # Allows overwriting an existing parameter
        )
        log.info "SSM Parameter set: #{name}"
      end
    end

    # There's a delete_parameters method also that can delete 10 at a time.
    # Use simple one-by-one deletion for clarity and to surface errors.
    # Will allow program to continue for ParameterNotFound error.
    # In case use wants to keep trying to delete all parameters.
    def delete(names)
      names.each do |name|
        name = conventional_name(name)
        ssm.delete_parameter(name: name)
        log.info "SSM Parameter deleted: #{name}"
      rescue Aws::SSM::Errors::ParameterNotFound => e
        log.warn "WARN: Failed to delete parameter #{name}: #{e.message}"
      end
    end

    def preview_list(names)
      names = names.is_a?(Hash) ? names.keys.map(&:to_s) : names
      names.map do |name|
        "  #{conventional_name(name)}"
      end.join("\n")
    end

    def conventional_name(name)
      # add conventional prefix
      # "/#{Jets.project.name}/#{Jets.env}/#{value}"
      unless name.include?("/")
        name = Jets::Dotenv::Convention.new.ssm_name(name)
      end
      name
    end
  end
end
