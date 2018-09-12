module Jets
  class Stack
    autoload :Parameter, 'jets/stack/parameter'
    include Parameter::Dsl
  end
end
