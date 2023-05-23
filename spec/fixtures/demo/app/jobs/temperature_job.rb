class TemperatureJob < ApplicationJob
  thermostat_rule(:room)
  def record
    # custom business logic
  end
end