module Jets
  module Gems
    autoload :Check, 'jets/gems/check'
    autoload :Exist, 'jets/gems/exist'
    autoload :Extract, 'jets/gems/extract'
    autoload :Report, 'jets/gems/report'

    def ruby_version_folder
      major, minor, patch = RUBY_VERSION.split('.')
      [major, minor, '0'].join('.') # 2.5.1 => 2.5.0
    end
    extend self
  end
end