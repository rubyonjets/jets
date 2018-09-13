require 'active_support/concern'

module Jets
  class Stack
    autoload :Base, 'jets/stack/base' # Registration and definitions
    autoload :Main, 'jets/stack/main'
    autoload :Parameter, 'jets/stack/parameter'
    autoload :Output, 'jets/stack/output'
    autoload :Resource, 'jets/stack/resource'
    autoload :Builder, 'jets/stack/builder'

    include Main::Dsl
    include Parameter::Dsl
    include Output::Dsl
    include Resource::Dsl
  end
end
