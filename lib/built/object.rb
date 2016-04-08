module Built
  # Built::Object is the unit of data in built.io
  class Object < BasicObject
    # Get / Set the uid for this object
    # @param [String] uid A valid object uid
    proxy_method :uid, true

    # Fetch the latest instance of this object from built
    # @raise BuiltError If the uid is not set
    # @return [Object] self
    def sync
      raise BuiltError, I18n.t("objects.uid_not_set") if Util.blank?(uid)
      instantiate(Built.client.request(uri).json["object"])
    end

    # Save / persist the object to built.io
    # @param [Hash] options Options
    # @option options [Boolean] :timeless Perform a timeless update
    # @option options [Boolean] :draft Save the object as draft
    # @option options [Boolean] :include_owner Include the owner of the object in the response
    # @option options [Boolean] :include Include a reference field in the response
    # @raise BuiltAPIError
    # @return [Object] self
    def save(options={})
      headers, query = {}, {}
      unpublish if options[:draft]
      query[:include_owner] = true if options[:include_owner]
      query[:include] = options[:include] if options[:include]

      if is_new?
        # create
        instantiate Built
          .client
          .request(uri, :post, wrap, nil, headers)
          .json["object"]
      else
        # TODO: Possibly remove this... very it is needed
        headers[:timeless] = true if options[:timeless]

        # update
        instantiate Built
          .client
          .request(uri, :put, wrap, nil, headers)
          .json["object"]
      end

      self
    end

    # Delete this object
    # @raise BuiltError If the object is not persisted
    # @return [Object] self
    def destroy
      raise BuiltError, I18n.t("objects.uid_not_set") if is_new?
      Built.client.request(uri, :delete)
      self.clear
      self
    end

    # Get the class in which this object belongs
    # @return [Class] class
    def get_class
      Built::Class.get(@class_uid)
    end

    # Assign references based on a condition
    # Searches for objects in the referred class and adds them as references
    # @param [String] path The reference field
    # @param [Query] query The query to apply when searching
    # @return [Object] self
    def set_reference_where(path, query)
      Util.type_check("path", path, String)
      Util.type_check("query", query, Query)

      self[path] = {"WHERE" => query.params["query"]}
      self
    end

    # Set reference for a field
    # The reference parameter can be an existing uid, an existing object,
    # or a new object. New objects will be created inline before being assigned
    # as references.
    # @param [String] path The path of the reference
    # @param [String, Object, Array<String>, Array<Object>] value The value to assign
    def set_reference(path, value)
      Util.type_check("path", path, String)
      value = value.is_a?(Array) ? value : [value]

      self[path] = value
        .map { |val|
          case val.class
          when String
            val
          when Built::Object
            val.is_new? ? val : val.uid
          else
            nil
          end
        }
        .compact

      self
    end

    # Decrement the value of a number field by the given number
    # @param [String] path The number field
    # @param [Fixnum] number The number to decrement
    # @return [Object] self
    def decrement(path, number=nil)
      Util.type_check("path", path, String)
      Util.type_check("number", number, Fixnum) if number
      self[path] = {"SUB" => number || 1}
      self
    end

    # Increment the value of a number field by the given number
    # @param [String] path The number field
    # @param [Fixnum] number The number to increment
    # @return [Object] self
    def increment(path, number=nil)
      Util.type_check("path", path, String)
      Util.type_check("number", number, Fixnum) if number
      self[path] = {"ADD" => number || 1}
      self
    end

    # Multiply the value of a number field by the given number
    # @param [String] path The number field
    # @param [Fixnum] number The number to multiply with
    # @return [Object] self
    def multiply(path, number)
      Util.type_check("path", path, String)
      Util.type_check("number", number, Fixnum)
      self[path] = {"MUL" => number}
      self
    end

    # Divide the value of a number field by the given number
    # @param [String] path The number field
    # @param [Fixnum] number The number to divide with
    # @return [Object] selfs
    def divide(path, number)
      Util.type_check("path", path, String)
      Util.type_check("number", number, Fixnum)
      self[path] = {"DIV" => number}
      self
    end

    # Update value at the given index for a multiple field
    # @param [String] path The field name on which the operation is to be applied
    # @param [#read] value Update the field with this value
    # @param [Fixnum] index
    # @return [Object] self
    def update_value(path, value, index)
      # TODO: convert these into operations that are transparently executed on save
      # The user should be able to access the values transparently.
      Util.type_check("path", path, String)
      Util.type_check("index", index, Fixnum)

      self[path] = {
        "UPDATE" => {
          "data" => value,
          "index" => index
        }
      }
      self
    end

    # Pull value from a multiple field
    # @param [String] path The field name on which the operation is to be applied
    # @param [#read] value Pull a certain value from the field
    # @param [Fixnum] index Pull a certain index from the field
    # @return [Object] self
    def pull_value(path, value = nil, index = nil)
      Util.type_check("path", path, String)
      Util.type_check("index", index, Fixnum) if index

      if value
        value = value.is_a?(Array) ? value : [value]

        self[path] = {
          "PULL" => {
            "data" => value
          }
        }
      elsif index
        self[path] = {
          "PULL" => {
            "index" => index
          }
        }
      else
        raise BuiltError, I18n.t("objects.pull_require")
      end

      self
    end

    # Push value into a multiple field
    # @param [String] path The field name on which the operation is to be applied
    # @param [#read] value Any value you wish to push
    # @param [Fixnum] index The index at which to push
    # @return [Object] self
    def push_value(path, value, index=nil)
      # TODO: also handle ability to push at nested multiples
      Util.type_check("path", path, String)
      Util.type_check("index", index, Fixnum) if index

      value = value.is_a?(Array) ? value : [value]

      self[path] = {"PUSH" => {"data" => value}}
      self[path]["PUSH"]["index"] = index unless Util.blank?(index)
      self
    end

    # Get the location object for this object
    # @return [Location]
    def location
      loc = self[Built::LOCATION_PATH]
      if loc
        Location.new(loc[0], loc[1])
      else
        nil
      end
    end

    # Set the location
    # @param [Location] loc The location object to set
    def location=(loc)
      Util.type_check("loc", loc, Location)
      self[Built::LOCATION_PATH] = loc.to_arr
      self
    end

    # Get ACL
    # @return [ACL]
    def ACL
      Built::ACL.new(self["ACL"])
    end

    # Set ACL
    # @param [ACL] acl
    # @return [Object] self
    def ACL=(acl)
      self["ACL"] = {
        "disable" => acl.disabled,
        "others" => acl.others,
        "users" => acl.users,
        "roles" => acl.roles
      }

      self
    end

    # Get the version this object is on
    def version
      self["_version"]
    end

    # Unpublish this object
    # @return [Object] self
    def unpublish
      self["published"] = false
      self
    end

    # Publish this object
    # @return [Object] self
    def publish
      self["published"] = true
      self
    end

    # Is this object published?
    # @return [Boolean]
    def is_published?
      self["published"]
    end

    # Get tags for this object
    def tags
      self["tags"] || []
    end

    # Add new tags
    # @param [Array<String>] tags An array of strings. Can also be a single tag.
    # @return [Object] self
    def add_tags(tags)
      tags = tags.is_a?(Array) ? tags : [tags]
      self["tags"] ||= []
      self["tags"].concat(tags)
      self
    end

    # Remove tags
    # @param [Array<String>] tags An array of strings. Can also be a single tag.
    # @return [Object] self
    def remove_tags(tags)
      tags = tags.is_a?(Array) ? tags : [tags]
      self["tags"] ||= []
      self["tags"] = self["tags"] - tags
      self
    end

    # Is this a new, unsaved object?
    # @return [Boolean]
    def is_new?
      Util.blank?(uid)
    end

    # Initialize a new object
    # @param [String] class_uid The uid of the class to which this object belongs
    # @param [String] uid The uid of an existing object, if this is an existing object
    def initialize(class_uid, uid=nil)
      unless Util.blank?(class_uid)
        raise BuiltError, I18n.t("objects.class_uid")
      end

      @class_uid = class_uid
      self.uid = uid unless Util.blank?(uid)

      clean_up!
      self
    end

    # @api private
    def instantiate(data)
      replace(data)
      clean_up!
      self
    end

    private

    def uri
      parts = [Built::Class.uri(@class_uid)]
      parts << (is_new? ? "objects" : "objects/#{uid}")
      parts.join("/")
    end

    def wrap
      changed_keys = self.changes.keys
      {:object => self.select { |o| changed_keys.include?(o) }}
    end

    def to_s
      "#<Built::Object uid=#{self[:uid]}, class_uid=#{@class_uid}>"
    end

    class << self
      # @api private
      def instantiate(data)
        new(data)
      end

      # @api private
      def uri(class_uid)
        "#{Built::Class.uri(class_uid)}/objects"
      end
    end
  end
end
