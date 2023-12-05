module Jets::Controller::Compat
  module Future
    # raise_on_missing_callback_actions will be called in Rails 7.1
    def raise_on_missing_callback_actions
      puts <<~EOL
        raise_on_missing_callback_actions called, Jets defaults to true so
        when we upgrade to Rails 7.1 components it'll trigger and will
        fix any issues. Also will need to make it configurable.
      EOL
      true
    end
  end
end
