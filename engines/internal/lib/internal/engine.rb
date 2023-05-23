module Jets::Internal
  # Reference: https://github.com/rails/rails/blob/master/actionmailer/lib/action_mailer/railtie.rb
  class Engine < ::Jets::Engine
  end
end

require_relative "actiondispatch"
require_relative "actionmailer"
require_relative "actionview"
require_relative "activerecord"
require_relative "activesupport"
require_relative "i18n_engine"
require_relative "jets_controller"
