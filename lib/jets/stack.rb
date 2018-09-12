module Jets
  class Stack
    autoload :Base, 'jets/stack/base'
    autoload :Parameter, 'jets/stack/parameter'
    autoload :Output, 'jets/stack/output'
    autoload :Common, 'jets/stack/common'

    include Common::Dsl
    include Parameter::Dsl
    include Output::Dsl
  end
end
