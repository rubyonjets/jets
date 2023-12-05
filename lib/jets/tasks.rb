# frozen_string_literal: true

require "rake"

# Load Jets Rakefile extensions
%w(
  framework
  log
  middleware
  misc
  tmp
  yarn
  zeitwerk
).tap { |arr|
  arr << "statistics" if Rake.application.current_scope.empty?
}.each do |task|
  load "jets/tasks/#{task}.rake"
end
