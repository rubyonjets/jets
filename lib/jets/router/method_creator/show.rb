class Jets::Router::MethodCreator
  class Show < Code
    def meth_name
      join(singularize(full_as), singularize(method_name_leaf))
    end
  end
end
