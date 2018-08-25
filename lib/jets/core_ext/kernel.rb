# Works with jets/io.rb
module Kernel
  @@io_buffer = []

  alias_method :original_puts, :puts
  def puts(message)
    message = "=> #{message}"
    @@io_buffer << message
    original_puts(message)
  end

  def io_buffer
    @@io_buffer
  end

  def io_flush
    IO.write("/tmp/jets-output.log", @@io_buffer.join("\n"))
    @@io_buffer = []
  end
end