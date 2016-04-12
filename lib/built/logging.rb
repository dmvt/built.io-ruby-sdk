require "faraday"

module Built
  module Logger
    # A Faraday middleware used for providing debug-level logging information.
    # The request and response logs follow very closely with cURL output for
    # ease of understanding.
    #
    # Be careful about your log level settings when using this middleware,
    # especially in a production environment. With a DEBUG level log enabled,
    # there will be potential information security concerns, because the
    # request and response headers and bodies will be logged out. At an INFO or
    # greater level, this is not a concern.
    #
    # CREDIT: https://github.com/envylabs/faraday-detailed_logger/blob/master/lib/faraday/detailed_logger/middleware.rb
    class Middleware < Faraday::Response::Middleware
      # Public: Initialize a new Logger middleware.
      #
      # app - A Faraday-compatible middleware stack or application.
      # logger - A Logger-compatible object to which the log information will
      #          be recorded.
      # progname - A String containing a program name to use when logging.
      #
      # Returns a Logger instance.
      #
      def initialize(app, logger)
        super(app)
        @logger = logger
      end

      # Public: Used by Faraday to execute the middleware during the
      # request/response cycle.
      #
      # env - A Faraday-compatible request environment.
      #
      # Returns the result of the parent application execution.
      #
      def call(env)
        @logger.info("#{env[:method].upcase} #{env[:url]}")
        @logger.debug(curl_output(env[:request_headers], env[:body]))
        super
      end

      # Internal: Used by Faraday as a callback hook to process a network
      # response after it has completed.
      #
      # env - A Faraday-compatible response environment.
      #
      # Returns nothing.
      #
      def on_complete(env)
        status = env[:status]
        log_response_status(status, "HTTP #{status}")
        @logger.debug(curl_output(env[:response_headers], env[:body]))
      end


      private


      def curl_output(headers, body)
        string = headers.collect { |k,v| "#{k}: #{v}" }.join("\n")
        string + "\n\n#{body}"
      end

      def log_response_status(status, msg)
        case status
        when 200..399
          @logger.info(msg)
        else
          @logger.warn(msg)
        end
      end
    end
  end
end

Faraday::Response.register_middleware(:built_logger => Built::Logger::Middleware)
