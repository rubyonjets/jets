# Works with jets/io.rb
module Kernel
  @@io_buffer = []

  # List from https://ruby-doc.org/core-2.5.1/Kernel.html
  # Note, will lose pp format in the @io_buffer but looks like a lot of work to keep the pp format.
  # Must override stdout which can be messy quick: https://www.ruby-forum.com/topic/43725
  OVERRIDE_METHODS = %w[
    p
    pp
    print
    printf
    putc
    puts
    sprintf
  ]
  OVERRIDE_METHODS.each do |meth|
    # Example of generated code:
    #
    #   alias_method :original_puts, :puts
    #   def puts(*args, &block)
    #     @@io_buffer << args.first # message
    #     original_puts(*args, &block)
    #   end
    #
    class_eval <<~CODE
      alias_method :original_#{meth}, :#{meth}
      def #{meth}(*args, &block)
        @@io_buffer << args.first # message
        original_#{meth}(*args, &block)
      end
    CODE
  end

  def io_buffer
    @@io_buffer
  end

  # Note: Writing binary data to the log will crash the process with an error like this:
  #   jets/lib/jets/core_ext/kernel.rb:20:in `write': "\x89" from ASCII-8BIT to UTF-8 (Encoding::UndefinedConversionError)
  # Rescue and discard it to keep the process alive.
  def io_flush
    chunk = @@io_buffer.join("\n")
    begin
      IO.write("/tmp/jets-output.log", chunk)
    # Writing to log with binary content will crash the process so rescuing it and writing an info message.
    rescue Encoding::UndefinedConversionError
      IO.write("/tmp/jets-output.log", "[BINARY DATA]")
    end
    @@io_buffer = []
  end
end