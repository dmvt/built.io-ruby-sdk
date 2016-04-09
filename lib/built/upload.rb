require "uri"

module Built
  class Upload < BasicObject
    include ACL::Helper
    include Instantiate
    include Tags

    class << self
      # @api private
      def uri
        "/uploads"
      end
    end

    # Get / Set the uid for this upload
    # @param [String] uid A valid upload uid
    proxy_method :uid, true

    # Set a new file
    # @param [File] file The file object to set
    def file=(file)
      Util.type_check("file", file, File)

      self[:upload] = file
      @file_set = file

      self
    end

    # URL for the upload
    # @return [String] url
    proxy_method :url

    # Fetch the latest instance of this upload from built
    # @raise BuiltError If the uid is not set
    # @return [Upload] self
    def sync
      raise BuiltError, I18n.t("objects.uid_not_set") if is_new?

      instantiate(Built.client.request(uri).json[:upload])
    end

    # Save / persist the upload to built.io
    # @param [Hash] options Options
    # @raise BuiltAPIError
    # @return [Object] self
    def save(options={})
      header = {"Content-Type" => "multipart/form-data"}

      if is_new?
        raise BuiltError, I18n.t("uploads.file_not_provided") unless @file_set

        # create
        instantiate Built
          .client
          .request(uri, :post, wrap, nil, header)
          .json[:upload]
      else
        # update
        instantiate Built
          .client
          .request(uri, :put, wrap, nil, header)
          .json[:upload]
      end

      @file_set = nil if @file_set

      self
    end

    # Delete this upload
    # @raise BuiltError If the uid is not set
    # @return [Upload] self
    def destroy
      raise BuiltError, I18n.t("objects.uid_not_set") if is_new?

      Built.client.request(uri, :delete)
      self.clear
      self
    end

    # Initialize a new upload
    # @param [String] uid The uid of an existing upload, if this is an existing upload
    def initialize(uid = nil)
      self.uid = uid if uid
      clean_up!
      self
    end

    private

    def uri
      parts = [self.class.uri]
      parts << uid unless is_new?
      parts.join("/")
    end

    def wrap
      data = {
        "PARAM" => Oj.dump(
          {:upload => self.select {|key| key != :upload}}
          :mode => :compat
        )
      }
      data["upload[upload]"] = self[:upload] if @file_set
      data
    end

    def to_s
      "#<Built::Upload uid=#{uid}>"
    end

    # Is this a new, unsaved object?
    # @return [Boolean]
    def is_new?
      Util.blank?(uid)
    end
  end
end
