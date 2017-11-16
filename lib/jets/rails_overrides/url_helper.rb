require "action_view"

# hackety hack
ActionView::Helpers::UrlHelper # trigger autoload
module ActionView::Helpers::UrlHelper
  # Basic implementation of url_for to allow use helpers without routes existence
  def url_for(options = nil) # :nodoc:
    puts "#{options.inspect}".colorize(:cyan)
    url = case options
          when String
            options
          when :back
            _back_url
          # TODO: hook this up to Jets implmentation of config/routes.rb
          # when ActiveRecord::Base
          #   record = options
          #   record.id
          else
            raise ArgumentError, "Please provided a String to link_to as the the second argument. The Jets link_to helper takes as the second argument."
          end

    url = add_stage_name(url)
    url
  end

private
  # Add API Gateway Stage Name
  def add_stage_name(url)
    puts "add_stage_name request.host #{request.host.inspect}"
    puts "add_stage_name url #{url.inspect}"
    puts "add_stage_name request.host.include?(\"amazonaws.com\") #{request.host.include?("amazonaws.com").inspect}"
    puts "add_stage_name url.starts_with?('/') #{url.starts_with?('/').inspect}"
    if request.host.include?("amazonaws.com") && url.starts_with?('/')
      stage_name = [Jets.config.short_env, Jets.config.env_extra].compact.join('_').gsub('-','_') # Stage name only allows a-zA-Z0-9_
      url = "/#{stage_name}#{url}"
    end

    url
  end
end
