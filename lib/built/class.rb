module Built
  # Built::Class provides the schema and provides grouping for 
  # different classes of objects.
  class Class < DirtyHashy
    include Built::Timestamps

    # Get the uid for this class
    def uid
      self["uid"]
    end

    # Get the title for this class
    def title
      self["title"]
    end

    # Is this an inbuilt class, provided by built.io?
    # @return [Boolean]
    def inbuilt_class?
      self["inbuilt_class"] == true
    end

    private

    def to_s
      "#<Built::Class uid=#{self["uid"]}, title=#{self["title"]}>"
    end

    class << self
      def instantiate(data)
        doc = new
        doc.replace(data)
        doc.clean_up!
        doc
      end

      # Get all classes from built. Returns an array of classes.
      # @raise Built::BuiltAPIError
      # @return [Array] classes An array of classes
      def get_all
        Built.client.request(uri)
          .parsed_response["classes"].map {|o| instantiate(o)}
      end

      # Get a single class by its uid
      # @raise Built::BuiltAPIError
      # @param [String] uid The uid of the class
      # @return [Class] class An instance of Built::Class
      def get(uid)
        instantiate(
          Built.client.request(uri(uid))
            .parsed_response["class"]
        )
      end

      # @api private
      def uri(class_uid=nil)
        class_uid ? "/classes/#{class_uid}" : "/classes"
      end
    end
  end
end