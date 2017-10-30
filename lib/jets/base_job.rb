require 'json'

module Jets
  class BaseJob < BaseModel
  private
    # meant to be overrriden by app classes but defining now to tes
    def perform
      puts "perform"
    end
  end
end