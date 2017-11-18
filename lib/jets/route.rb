# route = Jets::Route.new(
#   path: "posts",
#   method: :get,
#   to: "posts#index",
# )
class Jets::Route
  def initialize(options)
    @options = options
  end

  # IE: standard: posts/:id/edit
  #     api_gateway: posts/{id}/edit
  def path(api_gateway=false)
    if api_gateway
      api_gateway_format(@options[:path])
    else
      @options[:path]
    end
  end

  def method
    @options[:method].to_s.upcase
  end

  # IE: posts#index
  def to
    @options[:to]
  end

  # IE: PostsController
  def controller_name
    to.sub(/#.*/,'').camelize + "Controller"
  end

  # IE: index
  def action_name
    to.sub(/.*#/,'')
  end

  # Extracts the path parameters from the actual path
  # Only supports extracting 1 parameter. So:
  #
  #   actual_path: posts/tung/edit
  #   route.path: posts/:id/edit
  #
  # Returns:
  #    { id: "tung" }
  def extract_parameters(actual_path)
    if path.include?(':')
      extract_parameters_capture(actual_path)
    elsif path.include?('*')
      extract_parameters_proxy(actual_path)
    else
      # Lambda AWS_PROXY sets null to the input request when there are no path parmeters
      nil
    end
  end

  def extract_parameters_proxy(actual_path)
    # changes path to a string used for a regexp
    # others/*proxy => others\/(.*)
    # nested/others/*proxy => nested/others\/(.*)
    leading_path = path.split('/')[0..-2].join('/') # drop last segment
    # leading_path: nested/others

    # capture everything after the leading_path as the value
    regexp = Regexp.new("#{leading_path}/(.*)")
    value = actual_path.match(regexp)[1]

    # the last segment without the '*' is the key
    proxy_segment = path.split('/').last # last segment is the proxy segment
    # proxy_segment: *proxy
    key = proxy_segment.sub('*','')

    { key => value }
  end

  def extract_parameters_capture(actual_path)
    # changes path to a string used for a regexp
    # posts/:id/edit => posts\/(.*)\/edit
    regexp_string = path.split('/').map do |s|
                      s.include?(':') ? "([a-zA-Z0-9_]*)" : s
                    end.join('\/')
    # make sure beginning and end of the string matches
    regexp_string = "^#{regexp_string}$"
    regexp = Regexp.new(regexp_string)
    value = regexp.match(actual_path)[1]

    # only supports one path parameter key right now
    key = path.split('/').find {|s| s.include?(':') } # :id
    key = key.sub(':','')

    { key => value }
  end

private
  def api_gateway_format(path)
    path.split('/')
      .map {|s| transform_capture(s) }
      .map {|s| transform_proxy(s) }
      .join('/')
  end

  def transform_capture(text)
    if text.starts_with?(':')
      text = text.sub(':','')
      text = "{#{text}}"
    end
    text
  end

  def transform_proxy(text)
    if text.starts_with?('*')
      text = text.sub('*','')
      text = "{#{text}+}"
    end
    text
  end
end
