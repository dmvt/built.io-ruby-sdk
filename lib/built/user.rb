module Built
  class User < Built::Object
    # Create a new user object
    # @param [String] uid The uid of an existing user, if this is an existing user
    def initialize(uid=nil)
      super(Built::USER_CLASS_UID, uid)
    end

    # Assign authtoken for this user
    def authtoken=(token)
      @authtoken = token
      self["authtoken"] = token
    end

    # Get the authtoken for this user
    def authtoken
      @authtoken
    end

    # Logout a user
    def logout
      if !authtoken || (authtoken != Built.client.authtoken)
        raise BuiltError, I18n.t("users.not_logged_in")
      end

      Built.client.request(
        logout_uri,
        :delete
      )

      authtoken                 = nil
      Built.client.authtoken    = nil
      Built.client.current_user = nil

      self
    end

    # Update the user profile
    def update_user
      data = {
        self.class.user_wrapper => wrap.delete("object")
      }

      response = Built.client.request(uri, :put, data).json[self.class.user_wrapper]

      instantiate(response)

      self
    end

    # Delete / Deactivate the user. USE WITH CAUTION!
    def deactivate
      Built.client.request(uri, :delete)

      self.clear

      self
    end

    private

    def uri
      self.class.uri + '/#{uid}'
    end

    class << self
      # Login a user with an email and password
      # Once logged in, the user's authtoken will be used for all further requests
      # @param [String] email The user's email
      # @param [String] password The user's password
      def login(email, password)
        Util.type_check("email", email, String)
        Util.type_check("password", password, String)

        response = Built.client.request(
          login_uri,
          :post,
          {user_wrapper => {"email" => email, "password" => password}}
        ).json[user_wrapper]

        user                      = instantiate(response)
        user.authtoken            = response["authtoken"]
        Built.client.authtoken    = user.authtoken
        Built.client.current_user = user

        user
      end

      # TODO
      def login_with_google
      end

      # TODO
      def login_with_facebook
      end

      # TODO
      def login_with_tibbr
      end

      # TODO
      def login_with_twitter
      end

      # Fetch the current logged in user
      def current_user
        return Built.client.current_user if Built.client.current_user

        if Built.client.authtoken
          # we have the authtoken, but not the user
          # we'll fetch the user corresponding to the authtoken
          user = instantiate(Built.client.request(current_uri).json[user_wrapper])
          Built.client.current_user = user
        end

        Built.client.current_user
      end

      private

      def user_wrapper
        "application_user"
      end

      def wrap_in_user
        changed_keys = self.changes.keys
        {"application_user" => self.select {|o| changed_keys.include?(o)}}
      end

      def users_uri
        "/application/users"
      end

      def login_uri
        users_uri + "/login"
      end

      def logout_uri
        users_uri + "/logout"
      end

      def current_uri
        users_uri + '/current'
      end
    end
  end
end