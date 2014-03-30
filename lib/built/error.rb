module Built
  # Errors thrown by the library on invalid input
  class BuiltError < StandardError
  end

  # Errors thrown by the built.io API
  class BuiltAPIError < BuiltError
    attr_accessor :error_code
    attr_accessor :errors
    attr_accessor :error_message

    def initialize(response)
      @response = response

      if @response
        @error_code     = response["error_code"]
        @errors         = response["errors"]
        @error_message  = response["error_message"]
      end

      super("#{@error_code}: #{@error_message}")
    end

    private

    def to_s
      @error_message || super
    end
  end 
end