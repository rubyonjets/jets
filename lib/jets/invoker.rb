module Jets::Invoker
  def self.included(klass)
    klass.extend(ClassMethods)
  end

  def initialize(generator, *args)
    @generator = generator
    @args = args
  end

  def config
    g = Rails::Configuration::Generators.new
    g.orm             :active_record, migration: true, timestamps: true
    # TODO: support g.orm :dynamodb
    g.template_engine :erb
    g.test_framework  false #:test_unit, fixture: false
    # g.test_framework :rspec # need to
    # TODO: load rspec configuration to use rspec
    g.stylesheets     false
    g.javascripts     false
    g.assets          false
    g.api             Jets.config.mode == 'api'
    g.resource_route  true
    g.templates.unshift(template_paths)
    g
  end

  def template_paths
    templates_path = File.expand_path("../generator/templates", __FILE__)
    [templates_path]
  end

  module ClassMethods
    def invoke(generator, *args)
      new(generator, *args).invoke
    end
  end
end
