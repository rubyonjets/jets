module Kernel
  module_function

  alias_method :jets_original_require, :require
  # @param path [String]
  # @return [Boolean]
  def require(path)
    # Hack to prevent Jets const from being defined
    # Actionview requires "jets-html-sanitizer" and that creates a Jets module
    path = "jets-html-sanitizer" if path == "rails-html-sanitizer" && !ENV['JETS_RAILS_CONST']
    jets_original_require(path)
  end
end
