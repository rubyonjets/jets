module Jets::Controller::Response::Compat
  module Response
    extend ActiveSupport::Concern

    included do
      # Must come before include ActionDispatch::Http::Cache::Response
      # Aliasing these off because AD::Http::Cache::Response defines them.
      alias :_cache_control :cache_control
      alias :_cache_control= :cache_control=
    end

    class_methods do
      cattr_accessor :default_charset, default: "utf-8"
    end

    ContentTypeHeader = Struct.new :mime_type, :charset
    NullContentTypeHeader = ContentTypeHeader.new nil, nil

    CONTENT_TYPE = "Content-Type"
    CONTENT_TYPE_PARSER = /
      \A
      (?<mime_type>[^;\s]+\s*(?:;\s*(?:(?!charset)[^;\s])+)*)?
      (?:;\s*charset=(?<quote>"?)(?<charset>[^;\s]+)\k<quote>)?
    /x # :nodoc:

    def parse_content_type(content_type)
      if content_type && match = CONTENT_TYPE_PARSER.match(content_type)
        ContentTypeHeader.new(match[:mime_type], match[:charset])
      else
        NullContentTypeHeader
      end
    end

    # Small internal convenience method to get the parsed version of the current
    # content type header.
    def parsed_content_type_header
      parse_content_type(get_header("Content-Type"))
    end

    def set_content_type(content_type, charset)
      type = content_type || ""
      type = "#{type}; charset=#{charset.to_s.downcase}" if charset
      set_header CONTENT_TYPE, type
    end

    # Sets the HTTP character set. In case of +nil+ parameter
    # it sets the charset to +default_charset+.
    #
    #   response.charset = 'utf-16' # => 'utf-16'
    #   response.charset = nil      # => 'utf-8'
    def charset=(charset)
      content_type = parsed_content_type_header.mime_type
      if false == charset
        set_content_type content_type, nil
      else
        set_content_type content_type, charset || self.class.default_charset
      end
    end

    # The charset of the response. HTML wants to know the encoding of the
    # content you're giving them, so we need to send that along.
    def charset
      header_info = parsed_content_type_header
      header_info.charset || self.class.default_charset
    end
  end
end
