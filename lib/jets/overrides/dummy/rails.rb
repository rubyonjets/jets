# This is a dummy Rails class that delegates to Jets.
# It's only used for jets generate and jets db:migrate.
# It's easier to mock out the Rails module then to get them working.

module Rails
  cattr_accessor :application
  self.application = Jets.application
  class << self
    delegate :env, :root, to: Jets
  end
end
