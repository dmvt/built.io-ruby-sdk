module Built
  class Application < DirtyHashy
    include Built::Timestamps

    # Get the uid of this application
    def uid
      self["uid"]
    end

    # Get the name of this application
    def name
      self["name"]
    end

    # Get the api_key of this application
    def api_key
      self["api_key"]
    end

    private

    def to_s
      "#<Built::Application uid=#{uid}, api_key=#{api_key}>"
    end

    class << self
      def instantiate(data)
        doc = new
        doc.replace(data)
        doc.clean_up!
        doc
      end

      # Get the application you are working with
      # @return [Application]
      def get
        instantiate(
          Built.client.request(uri)
            .parsed_response["application"]
        )
      end

      # @api private
      def uri
        "/applications/myapp" # no longer require a valid uid to get the application
      end
    end
  end
end