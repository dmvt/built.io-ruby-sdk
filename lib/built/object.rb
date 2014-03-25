module Built
  # Built::Object is the unit of data in built.io
  class Object < Hash
    include Built::Timestamps

    # Get the uid for this object
    def uid
      self["uid"]
    end

    # Set the uid for this object
    # @param [String] uid A valid object uid
    def uid=(uid)
      self["uid"] = uid
    end

    # Fetch the latest instance of this object from built
    # @raise BuiltError If the uid is not set
    # @return [Object] self
    def fetch
      if !uid
        # uid is not set
        raise BuiltError, I18n.t("objects.uid_not_set")
      end

      self.merge!(
        Built.client.request(uri)
          .parsed_response["object"]
      )

      self
    end

    # Save / persist the object to built.io
    # @param [Hash] options Options
    # @option options [Boolean] :timeless Perform a timeless update
    # @option options [Boolean] :draft Save the object as draft
    # @raise BuiltAPIError
    # @return [Object] self
    def save(options={})
      if is_new?
        # create
        self.merge!(
          Built.client.request(uri, :post, wrap)
            .parsed_response["object"]
        )
      else
        headers = {}

        headers[:timeless] = true if options[:timeless]
        self["published"] = false if options[:draft]

        # update
        self.merge!(
          Built.client.request(uri, :put, wrap, nil, headers)
            .parsed_response["object"]
        )
      end
    end

    # Delete this object
    # @raise BuiltError If the uid is not set
    # @return [Object] self
    def destroy
      if !uid
        # uid is not set
        raise BuiltError, I18n.t("objects.uid_not_set")
      end

      Built.client.request(uri, :delete)

      self.clear

      self
    end

    # Get the class in which this object belongs
    # @return [Class] class
    def get_class
      Built::Class.get(@class_uid)
    end


    # Is this a new, unsaved object?
    # @return [Boolean]
    def is_new?
      Util.blank?(self["uid"])
    end

    # Initialize a new object
    # @param [String] class_uid The uid of the class to which this object belongs
    # @param [Hash] data Data to initialize the object with
    def initialize(class_uid, data=nil)
      if !class_uid
        raise BuiltError, I18n.t("objects.class_uid")
      end

      @class_uid  = class_uid

      if data
        self.merge!(data)
      end

      self
    end

    private

    def uri
      class_uri = Built::Class.uri(@class_uid)

      uid ? 
        [class_uri, "objects/#{uid}"].join("/") : 
        [class_uri, "objects"].join("/")
    end

    def wrap
      {"object" => self}
    end

    def to_s
      "#<Built::Object uid=#{self["uid"]}, class_uid=#{@class_uid}>"
    end

    class << self
      # @api private
      def uri(class_uid)
        class_uri = Built::Class.uri(class_uid)

        [class_uri, "objects"].join("/")
      end
    end
  end
end