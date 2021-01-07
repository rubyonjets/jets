# client-side require. Note: the server-side requires are in the Rakefile
require "opal"
require "opal-jquery"
require "browser"
require "browser/location"
require "native"
require "sidebar"
require "pager"

# use bin/rerun to continuously generate js/app.js from this file

Document.ready? do
  Sidebar.setup
  Pager.setup
end

