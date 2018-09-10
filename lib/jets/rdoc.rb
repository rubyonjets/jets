module Jets
  module Rdoc
    # Use for both jets.gemspec and rake rdoc task
    def options
      exclude = %w[
        docs
        spec
        vendor
        core.rb
        .js
        templates
        commands
        internal
        support
        Dockerfile
        Dockerfile.base
        Gemfile
        Gemfile.lock
        Guardfile
        LICENSE
        Procfile
        Rakefile
        bin
      ]
      exclude = exclude.map { |word| ['-x', word] }.flatten
      ["-m", "README.md", "--markup", "tomdoc"] + exclude
    end
    extend self
  end
end