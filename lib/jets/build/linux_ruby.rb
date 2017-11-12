require "fileutils"
require "open-uri"
require "colorize"
require "socket"
require "net/http"
require "pp"
require "action_view"

class Jets::Build
  RUBY_URL = 'https://s3.amazonaws.com/boltops-gems/rubies/ruby-2.4.2-linux-x86_64.tar.gz'.freeze

  class LinuxRuby
    include ActionView::Helpers::NumberHelper # number_to_human_size
    # TODO: update LinuxRuby with code from TravelingRuby
  end
end
