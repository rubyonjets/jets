class Jets::CLI::Schedule
  class Base < Jets::CLI::Base
    include Jets::Event::Dsl::RateExpression
  end
end
