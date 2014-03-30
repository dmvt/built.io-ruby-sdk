module Built
  class Client
    attr_accessor :authtoken
    attr_accessor :current_user

    def initialize(options={})
      @api_key    = options[:application_api_key]
      @master_key = options[:master_key]
      @host       = options[:host]
      @version    = options[:version]
      @authtoken  = options[:authtoken]

      # set the base uri
      @base_uri = @version ? [@host, @version].join('/') : @host
    end

    # perform a regular request
    def request(uri, method=:get, body=nil, query=nil, additionalHeaders={})
      options             = {}
      options[:url]       = @base_uri + uri
      options[:method]    = method

      options[:headers]   = {
        "application_api_key" => @api_key,
        "Content-Type"        => "application/json"
      }

      options[:headers][:params] = query if query

      options[:headers][:authtoken]   = @authtoken if @authtoken
      options[:headers][:master_key]  = @master_key if @master_key
      options[:headers].merge!(additionalHeaders)

      if body
        is_json = options[:headers]["Content-Type"] == "application/json"
        options[:payload] = is_json ? body.to_json : body
        unless is_json
          options[:headers].delete("Content-Type")
        end
      end

      begin
        response = Response.new(RestClient::Request.execute(options))
      rescue => e
        response = Response.new(e.response)
      end

      if !(200..299).include?(response.code)
        # error, throw it
        raise BuiltAPIError.new(response.json)
      end

      response
    end
  end

  class Response
    attr_reader :raw
    attr_reader :code
    attr_reader :body
    attr_reader :headers

    def initialize(response)
      @raw      = response
      @code     = response.code
      @body     = response.body
      @headers  = response.headers
    end

    def json
      JSON.parse @body
    end
  end
end