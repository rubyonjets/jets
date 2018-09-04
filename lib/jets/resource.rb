class Jets::Resource
  extend Memoist
  autoload :Interface, 'jets/resource/interface'
  include Interface

  autoload :Replacer, 'jets/resource/replacer'
  autoload :Permission, 'jets/resource/permission'
  autoload :Route, 'jets/resource/route'
  autoload :Cors, 'jets/resource/cors'
  autoload :RestApi, 'jets/resource/rest_api'

  def initialize(definition, replacements={})
    @definition = definition
    @replacements = replacements
  end

  def permission
    Permission.new(@replacements, self)
  end
  memoize :permission
end
