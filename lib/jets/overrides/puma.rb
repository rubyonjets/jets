require "puma/error_logger"
class Puma::ErrorLogger
  alias_method :original_title, :title
  def title(options={})
    string = original_title(options)
    error = options[:error]
    string << "\n#{error.backtrace.join("\n")}" if error
    string
  end
end
