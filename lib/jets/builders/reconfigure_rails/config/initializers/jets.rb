JetsRails.stage = ENV['JETS_STAGE'] || 'dev' # for jets-rails StageMiddleware

# config/s3_base_url.txt is generated as part of jets build process
s3_base_url = IO.read("#{Rails.root}/config/s3_base_url.txt").strip rescue "s3_base_url_placeholder"
asset_host = "#{s3_base_url}/rack/public"
Rails.application.config.action_controller.asset_host = asset_host
Rails.application.config.public_file_server.enabled = true

<% unless @api_mode -%>
# Rails.application.config.assets.quiet = false
Rails.application.config.assets.debug = false
Rails.application.config.assets.compile = false
<% end -%>

# Looks better without colorizatiion in CloudWatch logs
Rails.application.config.colorize_logging = false
