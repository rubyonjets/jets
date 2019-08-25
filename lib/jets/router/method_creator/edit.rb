class Jets::Router::MethodCreator
  class Edit < Code
    def meth_name
      path_items = @path.to_s.split('/')
      if method_name_leaf && path_items.size != 3
        nil # fallback: do not define url method
      else  # comes from resources
        join(action, singularize(full_as), singularize(method_name_leaf))
      end
    end
  end
end
