# frozen_string_literal: true

module Jets::Command
  class VersionCommand < Base # :nodoc:
    desc "version", "Prints Jets version"
    long_desc Help.text(:version)
    def perform
      puts Jets.version
    end
  end
end
