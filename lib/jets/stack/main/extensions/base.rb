module Jets::Stack::Main::Dsl
  module Base
    def ref(value)
      "!Ref #{value.to_s.camelize}"
    end

    def logical_id(value)
      value.to_s.camelize
    end

    def depends_on(*stacks)
      if stacks == []
        @depends_on
      else
        @depends_on ||= []
        @depends_on += stacks
      end
    end
  end
end