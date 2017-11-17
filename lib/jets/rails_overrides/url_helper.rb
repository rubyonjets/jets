require "action_view"

# hackety hack
module Jets
  module UrlHelper
    def link_to(name = nil, options = nil, html_options = nil, &block)
      # add class="jets-delete" to delete links for javascript to call it later
      if html_options&.[](:method) == :delete
        html_class = html_options[:class]
        html_options[:class] = [html_class, "jets-delete"].compact.join(' ')
      end
      super
    end

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
      if request.host.include?("amazonaws.com") && url.starts_with?('/')
        stage_name = [Jets.config.short_env, Jets.config.env_extra].compact.join('_').gsub('-','_') # Stage name only allows a-zA-Z0-9_
        url = "/#{stage_name}#{url}"
      end

      url
    end
  end # UrlHelper
end
ActionView::Helpers.send(:include, Jets::UrlHelper)
