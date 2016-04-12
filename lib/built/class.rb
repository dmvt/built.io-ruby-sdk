module Built
  # Built::Class provides the schema and provides grouping for
  # different classes of objects.
  class Class < BasicObject
    extend Instantiate::ClassMethods

    class << self
      # Get all classes from built. Returns an array of classes.
      # @raise Built::BuiltAPIError
      # @return [Array] classes An array of classes
      def get_all
        Built.client.request(uri).json[:classes].map { |o| instantiate(o) }
      end

      # Get a single class by its uid
      # @raise Built::BuiltAPIError
      # @param [String] uid The uid of the class
      # @return [Class] class An instance of Built::Class
      def get(uid)
        instantiate(Built.client.request(uri(uid)).json[:class])
      end

      # @api private
      def uri(class_uid=nil)
        class_uid ? "/classes/#{class_uid}" : "/classes"
      end
    end

    proxy_method :title
    proxy_method :uid

    # Is this an inbuilt class, provided by built.io?
    # @return [Boolean]
    def inbuilt_class?
      self[:inbuilt_class] == true
    end

    private

    def to_s
      "#<Built::Class uid=#{uid}, title=#{title}>"
    end
  end
end
