You can configure additional gem sources in config/application.rb:

    Jets.application.configure do
      config.gems.sources = [
        "https://gems.lambdagems.com"
      ]
    end