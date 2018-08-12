# Simple initial implementation of a prewarmer
class WarmJob < ApplicationJob
  rate '5 minutes'
  def preheat
    # load all classes
    # loop through all methods
    # make the special prewarm call to keep them warm
  end
end
