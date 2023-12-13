class ApplicationEvent < Jets::Event::Base
  # Adjust default timeout for all Event classes
  class_timeout 15.minutes
end
