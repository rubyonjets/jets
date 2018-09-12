module Jets
  class Stack
    autoload :Base, 'jets/stack/base' # Registration and definitions
    autoload :Common, 'jets/stack/common' # Things like `ref` method
    autoload :Parameter, 'jets/stack/parameter'
    autoload :Output, 'jets/stack/output'
    autoload :Resource, 'jets/stack/resource'

    include Common::Dsl
    include Parameter::Dsl
    include Output::Dsl
    include Resource::Dsl
  end
end
