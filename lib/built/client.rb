require "oj"

module Built
  class Client
    attr_accessor :authtoken
    attr_accessor :current_user

    def initialize(options={})
      @api_key    = options[:application_api_key]
      @master_key = options[:master_key]
      @host       = options[:host]
      @logger     = options[:logger]
      @authtoken  = options[:authtoken]
    end

    def api_request(url, method, params = nil, headers = {})
      method = method.to_s.downcase.to_sym unless method.is_a?(Symbol)
      args = [method, url]
      args << params unless Util.blank?(params)

      Faraday
        .new(@host) { |connection|
          connection.response(:logger, @logger) unless Utils.blank?(@logger)
          connection.adapter(Faraday.default_adapter)
        }
        .send(*args) { |request|
          build_headers(request, headers)
          yield(request) if block_given?
        }
    end

    def build_headers(request, headers = {})
      headers["Content-Type"] = "application/json"
      headers[:application_api_key] = @api_key
      headers[:authtoken] = @authtoken unless Util.blank?(@authtoken)
      headers[:master_key] = @master_key unless Util.blank?(@master_key)
      headers.each { |k, v| request.headers[k] = v }
    end

    # perform a regular request
    def request(uri, method = :get, body = nil, query = nil, headers = {})
      response = api_request(uri, method, query, headers) { |req|
        req.body = Oj.dump(body, :mode => :compat) unless Util.blank?(body)
      }

      Response.new(response)
    end
  end

  class Response
    attr_reader :raw
    attr_reader :code
    attr_reader :body
    attr_reader :headers

    def initialize(response)
      response.body.rewind
      @raw      = response
      @code     = response.status
      @body     = response.body.read
      @headers  = response.headers
      response.body.rewind
    end

    def json
      Oj.load @body, :symbol_keys => true
    end
  end
end
