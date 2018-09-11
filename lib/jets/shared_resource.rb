module Jets
  class SharedResource
    autoload :Sns, 'jets/shared_resource/sns'

    class << self
      def exists?
        true # TODO: remove this hardcode
      end

      def sns
        Sns.new(self)
      end
    end
  end
end