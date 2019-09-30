module Jets::Router::Dsl
  module Mount
    # The mounted class must be a Rack compatiable class
    def mount(klass, at:)
      options = {to: "jets/mount#call", mount_class: klass}
      at_wildcard = at.blank? ? "*path" : "#{at}/*path"

      any at, options
      any at_wildcard, options
    end
  end
end
