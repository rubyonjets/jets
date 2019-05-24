# Based on sinatra/cookies.rb
# https://github.com/sinatra/sinatra/blob/master/sinatra-contrib/lib/sinatra/cookies.rb
class Jets::Controller
  # = Jets::Controller::Cookies
  #
  # Easy way to deal with cookies
  #
  # == Usage
  #
  # Allows you to read cookies:
  #
  #   def index
  #     "value: #{cookies[:something]}"
  #   end
  #
  # And of course to write cookies:
  #
  #   def show
  #     cookies[:something] = 'foobar'
  #     render json: cookies
  #   end
  #
  # And generally behaves like a hash:
  #
  #   def index
  #     cookies.merge! 'foo' => 'bar', 'bar' => 'baz'
  #     cookies.keep_if { |key, value| key.start_with? 'b' }
  #     foo, bar = cookies.values_at 'foo', 'bar'
  #     puts "size: #{cookies.length}"
  #     render json: cookies
  #   end
  #
  module Cookies
    def cookies
      @cookies ||= Jar.new(self)
    end
  end
end