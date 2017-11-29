require 'thor'

# These commands are ran after rake webpacker:install to enhance the generated
# javascript assets to support Jets.
# Done this way so it works for both jets new and jets webpacker:install
class Jets::Commands::WebpackerTemplate < Thor::Group
  include Thor::Actions

  def self.source_root
    File.expand_path("new/templates/webpacker", File.dirname(__FILE__))
  end

  def reapply_templates
    # Always overwrite javascript webpacker:install created.
    directory "app/javascript", "app/javascript", force: true
  end
end
