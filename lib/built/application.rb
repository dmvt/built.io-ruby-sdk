module Built
  class Application < BasicObject
    proxy_method :api_key
    proxy_method :name
    proxy_method :uid

    private

    def to_s
      "#<Built::Application uid=#{uid}, api_key=#{api_key}>"
    end

    class << self
      def instantiate(data)
        new(data)
      end

      # Get the application you are working with
      # @return [Application]
      def get
        instantiate(
          Built.client.request(uri).json[:application]
        )
      end

      # @api private
      def uri
        "/applications/myapp"
      end
    end
  end
end
