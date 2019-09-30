module Jets::Router::Dsl
  module Mount
    # The mounted class must be a Rack compatiable class
    def mount(klass, at:)
      options = {to: "jets/mount#call", mount_class: klass}
      at = at[1..-1] if at.starts_with?('/') # be more forgiving if / accidentally included
      at_wildcard = at.blank? ? "*path" : "#{at}/*path"

      any at, options
      any at_wildcard, options
    end
  end
end
