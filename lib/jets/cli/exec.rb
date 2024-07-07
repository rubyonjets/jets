class Jets::CLI
  class Exec < Base
    def run
      klass = "Jets::CLI::Exec::#{deploy_type.to_s.camelize}".constantize
      strategy = klass.new(options)
      strategy.execute
    end
  end
end
