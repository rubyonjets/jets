module Jets
  class SharedResource
    autoload :Sns, 'jets/shared_resource/sns'

    class << self
      def build?
        true # always true, checked by cfn/builders/interface.rb
      end

      def sns
        Sns.new(self)
      end
    end
  end
end