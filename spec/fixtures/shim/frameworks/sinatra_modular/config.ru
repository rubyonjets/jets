require "sinatra/base"

class MyApp < Sinatra::Base
  get "/" do
    "hello world"
  end
end
