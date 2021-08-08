require "action_view"

# hackety hack
module Jets::UrlHelper
  include Jets::CommonMethods

  # Basic implementation of url_for to allow use helpers without routes existence
  def url_for(options = nil) # :nodoc:
    url = if options.is_a?(String)
            options
          elsif options == :back
            _back_url
          elsif options.respond_to?(:to_model)
            _handle_model(options)
          elsif options.is_a?(Array)
            _handle_array(options)
          else
            raise ArgumentError, "The Jets link_to helper only supports some types of arguments. Please provided a String or an object that supports ActiveModel to link_to as the the second argument."
          end

    add_stage_name(url)
  end

  def _handle_model(record)
    model = record.to_model
    if model.persisted?
      meth = model.model_name.singular_route_key + "_path"
      send(meth, record) # Example: post_path(record)
    else
      meth = model.model_name.route_key + "_path"
      send(meth) # Example: posts_path
    end
  end

  # Convention is that the model class name is the method name. Doesnt work if user is using as.
  def _handle_array(array)
    contains_nil = !array.select(&:nil?).empty?
    if contains_nil
      raise "ERROR: You passed a nil value in the Array. #{array.inspect}."
    end

    last_persisted = nil
    items = array.map do |x|
      if x.is_a?(ActiveRecord::Base)
        last_persisted = x.persisted?
        x.persisted? ? x.model_name.singular_route_key : x.model_name.route_key
      else
        x
      end
    end
    meth = items.join('_') + "_path"

    args = array.clone
    args.shift if args.first.is_a?(Symbol) # drop the first element if its a symbol
    args = last_persisted ? args : args[0..-2]

    # post_comment_path(post_id) - keep all args - for update
    # post_comments_path - drop last arg - for create
    send(meth, *args)
  end

  # for forgery protection
  def token_tag(token = nil, form_options: {})
    return '' unless protect_against_forgery?

    hidden_field_tag 'authenticity_token', masked_authenticity_token
  end

  def masked_authenticity_token
    @masked_authenticity_token ||= SecureRandom.hex(32)
    session[:authenticity_token] = @masked_authenticity_token
  end

  def protect_against_forgery?
    @_jets[:controller].class.forgery_protection_enabled?
  end

  def csrf_meta_tags
    if protect_against_forgery?
      html = tag("meta", name: "csrf-token", content: masked_authenticity_token).html_safe
      html << "\n"
      html << tag("meta", name: "csrf-param", content: "authenticity_token").html_safe
      html
    end
  end
end # UrlHelper

ActionView::Helpers.send(:include, Jets::UrlHelper)
