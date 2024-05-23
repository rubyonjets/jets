module Jets::Util
  module Logging
    # Both work within the Jets source code.
    #
    #   logger.info
    #   log.info (encouraged)
    #
    # Jets.logger also points to this via jets/core.rb by default.
    # Hoewever, it can be overridden by other frameworks.
    #
    delegate :logger, to: "Jets.bootstrap.config"
    def log
      logger
    end
  end
end
