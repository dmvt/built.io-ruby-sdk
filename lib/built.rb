require "i18n"

module Built
  class << self
    # singleton http client
    # @api private
    @@client = nil

    # Initialize the SDK
    # @raise [BuiltError]
    # @param [Hash] options Options
    # @option options [String] :application_api_key Your app's api_key. Required.
    # @option options [String] :master_key Your app's master_key
    # @option options [String] :authtoken A user's authtoken
    # @option options [String] :host built.io API host (defaults to https://api.built.io)
    # @option options [String] :version built.io version delimiter (v1, v2, etc)
    def init(options)
      options ||= {}

      host        = options[:host]    || Built::API_URI
      version     = options[:version] || Built::API_VERSION
      master_key  = options[:master_key]
      api_key     = options[:application_api_key]
      authtoken   = options[:authtoken]

      if Util.blank?(api_key)
        raise BuiltError, I18n.t(
          "required_parameter", {:param => "application_api_key"})
      end

      # create the client
      @@client = Client.new({
        host:                 host,
        version:              version,
        application_api_key:  api_key,
        master_key:           master_key,
        authtoken:            authtoken
      })
    end

    # Get the singleton client
    # @api private
    def client
      if !@@client
        raise BuiltError, I18n.t("not_initialized")
      end

      @@client
    end

    # @api private
    def root
      File.expand_path '..', __FILE__
    end
  end
end

require "built/constants"
require "built/i18n"
require "built/util"
require "built/error"
require "built/client"
require "built/timestamps"
require "built/application"
require "built/class"
require "built/object"
require "built/query"
require "built/location"
require "built/acl"
require "built/user"
require "built/role"
require "built/installation"
require "built/upload"
