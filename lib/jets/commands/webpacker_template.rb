require 'thor'

# These commands are ran after rake webpacker:install to enhance the generated
# javascript assets to support Jets.
# Done this way so it works for both jets new and jets webpacker:install
class Jets::Commands::WebpackerTemplate < Thor::Group
  include Thor::Actions

  class_option :force, desc: "Bypass confirmation and overwrite existing files."
  class_option :bootstrap, type: :boolean, default: true, desc: "Install bootstrap"
  def self.source_root
    File.expand_path("templates/webpacker", File.dirname(__FILE__))
  end

  def reapply_templates
    directory "app/javascript", "app/javascript", force: options[:force]#, bootstrap: options[:bootstrap]
  end
end
