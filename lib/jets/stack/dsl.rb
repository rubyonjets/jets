class Jets::Stack
  module Dsl
    extend ActiveSupport::Concern

    include Main
    include Output
    include Parameter
    include Resource
  end
end
