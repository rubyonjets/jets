# frozen_string_literal: true

require "jets/dev_caching"

module Jets
  module Command
    class DevCommand < Base # :nodoc:
      no_commands do
        def help
          say "jets dev:cache # Toggle development mode caching on/off."
        end
      end

      def cache
        Jets::DevCaching.enable_by_file
      end
    end
  end
end
