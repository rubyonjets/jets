module Jets::Cfn::Iam
  # Examples:
  # config.codebuild.iam.policies = ["s3", "ec2"]
  # config.codebuild.iam.policies = [
  #   "s3",
  #   {
  #     PolicyName: "hello",
  #     PolicyDocument: {
  #       Version: "2012-10-17",
  #       Statement: [{Action: ["s3:*"], Effect: "Allow", Resource: "*"}]
  #     }
  #   }
  # ]
  class Policy
    def initialize(policy_name, definitions)
      @policy_name, @definitions = policy_name, definitions.compact.flatten.uniq
    end

    # Returns a standardize policy document. Example:
    #   {
    #     PolicyName: "hello",
    #     PolicyDocument: {
    #       Version: "2012-10-17",
    #       Statement: [{Action: ["s3:*"], Effect: "Allow", Resource: "*"}]
    #     }
    #   }
    #
    # A definition is a String or a Hash. It's very close to a Statement
    #   String: "s3"
    #   Hash: {Action: ["s3:*"], Effect: "Allow", Resource: "*"} # Action item
    def standardize
      return if @definitions.nil? || @definitions.empty?

      if @definitions.is_a?(Hash)
        standardize_hash(@definitions) # final policy
      else # Array of definitions
        statement = statement_from_array(@definitions) # statement is Array
        # final policy
        # Note since we always extract the statement we ignore the PolicyDocument Version
        # and always use 2012-10-17
        {
          PolicyName: @policy_name,
          PolicyDocument: {
            Version: "2012-10-17",
            Statement: statement
          }
        }
      end
    end

    def statement_from_array(definitions)
      if definitions.all? { |definition| definition.is_a?(String) }
        statement_from_all_strings(definitions)
      else
        definitions.map do |definition|
          if definition.is_a?(String)
            statement_from_string(definition)
          else # assume hash
            statement_from_hash(definition) # possible Array or Hash
          end
        end.flatten # due to statement_from_hash
      end
    end

    def all_actions_colon_star(action)
      action.include?(":") ? action : "#{action}:*"
    end

    def statement_from_all_strings(definitions)
      action = definitions.map do |definition|
        all_actions_colon_star(definition)
      end
      [Action: action, Effect: "Allow", Resource: "*"]
    end

    def statement_from_string(definition)
      action = [all_actions_colon_star(definition)]
      [Action: action, Effect: "Allow", Resource: "*"]
    end

    def statement_from_hash(definition)
      if definition.key?(:Statement) # full PolicyDocument. Has Version and Statement
        # Will have an Array of Statements that needs to be flattened later
        definition[:Statement] # This is an Array
      elsif definition.key?(:Action)
        definition
      else
        definition.merge(Action: [all_actions_colon_star(definition[:Action])])
      end
    end

    # Example return value:
    #   - Effect: Allow
    #     Action: '*'
    #     Resource: '*'
    def standardize_hash(hash)
      if hash.key?(:Action)
        {
          PolicyName: @policy_name,
          PolicyDocument: {
            Version: "2012-10-17",
            Statement: [hash]
          }
        }
      elsif hash.key?(:Statement)
        {
          PolicyName: @policy_name,
          PolicyDocument: hash
        }
      elsif hash.key?(:PolicyDocument)
        if hash.key?(:PolicyName)
          hash # full hash with both PolicyName and PolicyDocument
        else
          hash.merge(PolicyName: @policy_name) # almost full hash with PolicyDocument
        end
      else
        raise "Invalid hash format: #{hash.inspect}"
      end
    end
  end
end
