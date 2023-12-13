require "fugit"

module Jets::Event::Dsl
  module RateExpression
    # normalizes the rate expression
    def rate_expression(expr)
      duration = Fugit::Duration.parse(expr)
      map = {
        sec: "second",
        min: "minute",
        hou: "hour",
        day: "day",
        wee: "week",
        mon: "month",
        yea: "year"
      }
      # duration.h has a hash like {:hou=>1}. unit is truncated to 3 characters
      h = duration.h # IE: {:hou=>1}
      value = h.values.first
      unit = h.keys.first
      unit = map[unit]
      # Fix the unit to be singular or plural for user
      unit = (value > 1) ? unit.pluralize : unit.singularize
      "#{value} #{unit}"
    end
  end
end
