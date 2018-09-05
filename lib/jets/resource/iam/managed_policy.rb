module Jets::Resource::Iam
  class ManagedPolicy
    extend Memoist

    attr_reader :definitions
    def initialize(*definitions)
      @definitions = definitions.flatten.compact
    end

    def arns
      definitions.map { |definition| standardize(definition) }
    end
    memoize :arns # only process arns once

    # AmazonEC2ReadOnlyAccess => arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess
    def standardize(definition)
      return definition if definition.include?('iam::aws:policy')

      "arn:aws:iam::aws:policy/#{definition}"
    end
  end
end
