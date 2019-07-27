class Jets::Router::MethodCreator
  class Edit < Code
    def meth_name
      join(action, singularize(full_as), singularize(method_name_leaf))
    end
  end
end
