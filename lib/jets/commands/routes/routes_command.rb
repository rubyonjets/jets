# frozen_string_literal: true

require "cli-format"

module Jets::Command
  class RoutesCommand < Base # :nodoc:
    option :controller, aliases: :c, desc: "Filter by a specific controller, e.g. PostsController or Admin::PostsController"
    option :format, default: "table", desc: "Output formats: #{CliFormat.formats.join(', ')}" # csv, equal, json, space, table, tab
    option :grep, aliases: :g, desc: "Grep routes by a specific pattern"
    option :reject, aliases: :r, desc: "Reject filter routes by a specific pattern"

    desc "routes", "Print out your application routes"
    long_desc Help.text(:routes)
    def perform(*)
      require_application_and_environment!
      Jets::Router::Help.new(options).print
    end
  end
end
