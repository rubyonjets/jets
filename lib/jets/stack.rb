module Jets
  class Stack
    autoload :Base, 'jets/stack/base'
    autoload :Parameter, 'jets/stack/parameter'
    autoload :Output, 'jets/stack/output'

    include Parameter::Dsl
    include Output::Dsl
  end
end
