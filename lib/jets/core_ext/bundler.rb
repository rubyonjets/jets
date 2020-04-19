# Bundler 2.0 does yet not have with_unbundled_env
# Bundler 2.1 deprecates with_unbundled_env for with_unbundled_env

require "bundler"
def Bundler.with_unbundled_env(&block)
  with_clean_env(&block)
end unless Bundler.respond_to?(:with_unbundled_env)
