module Built
  class Client
    include HTTMultiParty

    def initialize(options={})
      @api_key    = options[:application_api_key]
      @master_key = options[:master_key]
      @host       = options[:host]
      @version    = options[:version]
      @authtoken  = options[:authtoken]

      # set the base uri
      self.class.base_uri @version ? [@host, @version].join('/') : @host
    end

    # set the authtoken
    def authtoken=(authtoken)
      @authtoken = authtoken
    end

    # perform a regular request
    def request(uri, method=:get, body=nil, query=nil, additionalHeaders={})
      options             = {}
      options[:query]     = query if query
      options[:body]      = body.to_json if body

      options[:headers]   = {
        "application_api_key" => @api_key,
        "Content-Type"        => "application/json"
      }

      options[:headers][:authtoken]   = @authtoken if @authtoken
      options[:headers][:master_key]  = @master_key if @master_key
      options[:headers].merge!(additionalHeaders)

      response = self.class.send(method, uri, options)

      if ![200, 201, 204].include?(response.code)
        # error, throw it
        raise BuiltAPIError.new(response.parsed_response)
      end

      response
    end
  end
end