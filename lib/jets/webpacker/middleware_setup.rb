# Breaking all the rules to get the beautiful webpacker middleware working

require "webpacker"
require "webpacker/helper"
require "webpacker/dev_server_proxy"
require "active_support/core_ext/object"
require "active_support/core_ext/hash"

ActiveSupport.on_load :action_controller do
  ActionController::Base.helper Webpacker::Helper
end

ActiveSupport.on_load :action_view do
  include Webpacker::Helper
end

Webpacker.bootstrap # whenever jets server is runs should Webpacker.bootstrap
