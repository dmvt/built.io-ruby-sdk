require "i18n"
require "oj"

module Built
  class << self
    # Initialize the SDK
    # @raise [BuiltError]
    # @param [Hash] options Options
    # @option options [String] :application_api_key Your app's api_key. Required.
    # @option options [String] :master_key Your app's master_key
    # @option options [String] :authtoken A user's authtoken
    # @option options [String] :host built.io API host (defaults to https://api.built.io)
    # @option options [Logger] :logger A Logger (or compatible) instance
    def init(options)
      options ||= {}

      host       = options[:host] || Built::API_URI
      master_key = options[:master_key]
      api_key    = options[:application_api_key]
      authtoken  = options[:authtoken]
      logger     = options[:logger]

      if Util.blank?(api_key)
        message = I18n.t("required_parameter", :param => "application_api_key")
        raise BuiltError, message
      end

      # create the client
      @client = Client.new({
        :host => host,
        :application_api_key => api_key,
        :master_key => master_key,
        :authtoken => authtoken,
        :logger => logger
      })
    end

    # Get the singleton client
    # @api private
    def client
      raise BuiltError, I18n.t("not_initialized") if Util.blank?(@client)
      @client
    end

    # @api private
    def root
      File.expand_path "..", __FILE__
    end
  end
end

require "built/constants"
require "built/logging"
require "built/i18n"
require "built/util"
require "built/error"
require "built/tags"
require "built/instantiate"

require "built/client"
require "built/acl"
require "built/basic_object"
require "built/application"
require "built/class"
require "built/object"
require "built/query"
require "built/location"
require "built/user"
require "built/role"
require "built/installation"
require "built/upload"
