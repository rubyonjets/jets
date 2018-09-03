# Works with jets/io.rb
module Kernel
  @@io_buffer = []

  alias_method :original_puts, :puts
  def puts(message)
    @@io_buffer << message
    original_puts(message)
  end

  # TODO: implement other methods that write output:
  # p, print, printf, putc, puts, sprintf?
  # Also, would be nice to figure out pp method also.

  def io_buffer
    @@io_buffer
  end

  # Note: Writing binary data to the log will crash the process with an error like this:
  #   jets/lib/jets/core_ext/kernel.rb:20:in `write': "\x89" from ASCII-8BIT to UTF-8 (Encoding::UndefinedConversionError)
  # So rescuring it and discarding it to keep the process alive.
  def io_flush
    chunk = @@io_buffer.join("\n")
    begin
      IO.write("/tmp/jets-output.log", chunk)
    # Writing to log with binary content will crash the process so rescuing it and writing an info message.
    rescue Encoding::UndefinedConversionError => e
      error_message = "Encoding::UndefinedConversionError: Binary data was written to Jets::IO buffer. Writing binary data to the log will crash the process, so discarding it.  This is an info message only. If you want to return binary data please base64 encode the data."
      IO.write("/tmp/jets-output.log", error_message)
    end
    @@io_buffer = []
  end
end