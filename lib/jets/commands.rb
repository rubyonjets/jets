# frozen_string_literal: true

require "jets/command"

aliases = {
  "g"  => "generate",
  "c"  => "console",
  "s"  => "server",
  "db" => "dbconsole",
  "r"  => "runner",
  "t"  => "test"
}

command = ARGV.shift
command = aliases[command] || command

Jets::Command.invoke command, ARGV
