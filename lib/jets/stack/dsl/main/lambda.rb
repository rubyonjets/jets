module Jets::Stack::Dsl::Main
  module Lambda
    # Example:
    #
    #   function(:hello,
    #     handler: handler("hello.lambda_hander"),
    #     runtime: "python3.6"
    #   )
    #
    # Defaults to ruby. So:
    #
    #   function(:hello)
    #
    # is the same as:
    #
    #   function(:hello,
    #     handler: handler("hello.hande"),
    #     runtime: :ruby
    #   )
    #
    def function(id, props = {})
    end
    alias_method :ruby_function, :function
    alias_method :lambda_function, :function

    def python_function(id, props = {})
    end

    def node_function(id, props = {})
    end

    # Usage:
    #
    #   permission(:my_permission, principal: "events.amazonaws.com")
    #
    def permission(id, props = {})
    end
  end
end
