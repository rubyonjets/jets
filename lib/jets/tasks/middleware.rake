# frozen_string_literal: true

desc "Prints out your Rack middleware stack"
task middleware: :environment do
  Jets.configuration.middleware.each do |middleware|
    puts "use #{middleware.name}"
  end
  puts "run #{Jets.application.endpoint}"
end
