class Jets::Router::MethodCreator
  class Generic < Code
    def meth_name
      @options[:as]
    end

    def path_method
      super if @options[:as]
    end
  end
end
