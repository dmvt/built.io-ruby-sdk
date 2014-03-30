require "uri"

module Built
  class Upload < DirtyHashy
    include Built::Timestamps

    # Get the uid for this upload
    def uid
      self["uid"]
    end

    # Set the uid for this upload
    # @param [String] uid A valid upload uid
    def uid=(uid)
      self["uid"] = uid
    end

    # Set a new file
    # @param [File] file The file object to set
    def file=(file)
      Util.type_check("file", file, File)

      self["upload"]  = file
      @file_set       = file

      self
    end

    # URL for the upload
    # @return [String] url
    def url
      self["url"]
    end

    # Fetch the latest instance of this upload from built
    # @raise BuiltError If the uid is not set
    # @return [Upload] self
    def sync
      if !uid
        # uid is not set
        raise BuiltError, I18n.t("objects.uid_not_set")
      end

      instantiate(
        Built.client.request(uri)
          .json["upload"]
      )

      self
    end

    # Save / persist the upload to built.io
    # @param [Hash] options Options
    # @raise BuiltAPIError
    # @return [Object] self
    def save(options={})
      header = {"Content-Type" => "multipart/form-data"}

      if is_new?
        unless @file_set
          raise BuiltError, I18n.t("uploads.file_not_provided")
        end

        # create
        instantiate(
          Built.client.request(uri, :post, wrap, nil, header)
            .json["upload"]
        )
      else
        # update
        instantiate(
          Built.client.request(uri, :put, wrap, nil, header)
            .json["upload"]
        )
      end

      if @file_set
        @file_set = nil
      end

      self
    end

    # Delete this upload
    # @raise BuiltError If the uid is not set
    # @return [Upload] self
    def destroy
      if !uid
        # uid is not set
        raise BuiltError, I18n.t("objects.uid_not_set")
      end

      Built.client.request(uri, :delete)

      self.clear

      self
    end

    # Get tags for this upload
    def tags
      self["tags"] || []
    end

    # Add new tags
    # @param [Array] tags An array of strings. Can also be a single tag.
    def add_tags(tags)
      tags = tags.is_a?(Array) ? tags : [tags]
      self["tags"] ||= []
      self["tags"].concat(tags)
      self
    end

    # Remove tags
    # @param [Array] tags An array of strings. Can also be a single tag.
    def remove_tags(tags)
      tags = tags.is_a?(Array) ? tags : [tags]
      self["tags"] ||= []
      self["tags"] = self["tags"] - tags
      self
    end

    # Initialize a new upload
    # @param [String] uid The uid of an existing upload, if this is an existing upload
    def initialize(uid=nil)
      if uid
        self.uid = uid
      end

      clean_up!
      self
    end

    # @api private
    def instantiate(data)
      replace(data)
      clean_up!
      self
    end

    # Get ACL
    # @return [ACL]
    def ACL
      Built::ACL.new(self["ACL"])
    end

    # Set ACL
    # @param [ACL] acl
    def ACL=(acl)
      self["ACL"] = {
        "disable" => acl.disabled,
        "others" => acl.others,
        "users" => acl.users,
        "roles" => acl.roles
      }

      self
    end

    private

    def uri
      uid ? 
        [self.class.uri, uid].join("/") : 
        self.class.uri
    end

    def wrap
      data = {
        "PARAM" => {"upload" => self.select {|key| key != "upload"}}.to_json
      }

      if @file_set
        data["upload[upload]"] = self["upload"]
      end

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

    class << self
      def instantiate(data)
        doc = new
        doc.instantiate(data)
      end

      # @api private
      def uri
        "/uploads"
      end
    end
  end
end