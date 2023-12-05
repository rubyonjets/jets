# frozen_string_literal: true

require 'base64'

module Jets
  module SpecHelpers
    include Fixtures
    include Controllers
  end
end

require "rspec"
RSpec.configure do |c|
  c.include Jets::SpecHelpers
end
