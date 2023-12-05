module Jets::Controller::Decorate
  module Logging
    extend ActiveSupport::Concern

    included do
      # A little bit tricky. Jets::Controller::Base includes AbstractController::Logger
      # via ActionController::Redirecting.
      # AbstractController::Logger defines a config_accessor :logger
      # This results in logger being nil.  We set it to logger here to correct it.
      # Unsure why this does not happen with ActionController::Base though.
      delegate :logger, to: Jets # fixes logger but Rails doesnt need this
    end

    def dispatch!
      t1 = Time.now
      log_start
      triplet = super # Abstract#dispatch!
      took = Time.now - t1
      log_finish status: status, took: took
      triplet
    end

    def processing_log
      processing = "Processing #{self.class.name}##{@meth}"
      processing << " (original method #{@original_meth})" if @original_meth
      processing
    end

    # Documented interface method, careful not to rename
    def log_start
      # Commented out Started because Jets::Rack::Logger middleware handles now
      # ip = request.ip
      # logger.info "Started (Jets) #{request.request_method} \"#{request.path}\" for #{ip} at #{Time.now}"

      logger.info processing_log
      logger.info "  Raw Event: #{@event}" if ENV['JETS_LOG_RAW_EVENT']
      logger.info "  Event: #{event_log}" if log_event?
      params = filtered_parameters.to_h.except('controller', 'action')
      # JSON.dump makes logging look pretty in CloudWatch logs because it keeps it on 1 line
      logger.info "  Parameters: #{JSON.dump(params)}" unless params.empty?
    end

    def log_event?
      return false if ENV['JETS_LOG_EVENT'] == '0'
      Jets.config.logging.event
    end

    # Documented interface method, careful not to rename
    def log_finish(options={})
      status, took = options[:status], options[:took]
      logger.info "Completed Status Code #{status} in #{"%.3f" % took}s"
    end

    def event_log
      event = @event.dup # clone to display event

      if event['isBase64Encoded']
        event['body'] = '[BASE64_ENCODED]'
      else
        event['body'] = filter_json_log(event['body'])
      end

      event["multiValueQueryStringParameters"] = parameter_filter.filter(event['multiValueQueryStringParameters']) if event['multiValueQueryStringParameters']
      event["pathParameters"] = parameter_filter.filter(event['pathParameters']) if event['pathParameters']
      event["queryStringParameters"] = parameter_filter.filter(event['queryStringParameters']) if event['queryStringParameters']
      json_dump_log(event)
    end

    # Append _log to reduce chance of name collision with user defined methods
    def filter_json_log(json_text)
      return json_text if json_text.blank?

      begin
        hash_params = JSON.parse(json_text)
        filtered_params = parameter_filter.filter(hash_params)
        JSON.dump(filtered_params)
      rescue JSON::ParserError
        '[FILTERED]'
      end
    end

    # Handles binary data safely
    def json_dump_log(data)
      JSON.dump(data)
    rescue Encoding::UndefinedConversionError
      data['body'] = '[BINARY]'
      JSON.dump(data)
    end
  end
end
