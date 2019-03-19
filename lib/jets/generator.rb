# Piggy back off of Rails Generators.
class Jets::Generator
  def self.invoke(generator, *args)
    new(generator, *args).invoke
  end

  def self.revoke(generator, *args)
    new(generator, *args).revoke
  end

  def initialize(generator, *args)
    @generator, @args = generator, args
    # lazy require so Rails const is only defined when using generators
    require "rails/generators"
    require "rails/configuration"
    Rails::Generators.configure!(config)
  end

  def invoke ; run(:invoke) ; end
  def revoke ; run(:revoke) ; end

  def run(behavior=:invoke)
    Rails::Generators.invoke(@generator, @args, behavior: behavior, destination_root: Jets.root)
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
end
