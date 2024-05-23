class Jets::CLI::Env
  module Parse
    def parse_cli_env_values(pairs)
      # Use each_with_object to iterate over the pairs and insert them into a hash
      pairs.each_with_object({}) do |pair, hash|
        key, value = pair.split("=")
        hash[key] = value
      end
    end
  end
end
