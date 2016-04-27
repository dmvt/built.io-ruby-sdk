module Built
  class ACL
    module Helper
      # Get ACL
      # @return [ACL]
      def ACL
        Built::ACL.new(self[:ACL], self[:app_user_object_uid])
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
    end

    attr_accessor :disabled
    attr_accessor :others
    attr_accessor :users
    attr_accessor :roles

    def initialize(data, uid)
      data ||= {}

      @uid = uid
      @disabled = data[:disable] == true
      @others = data[:others] || {}
      @users = data[:users] || []
      @roles = data[:roles] || []
      @can = data[:can] || []
    end

    # Disable / Enable ACL ============================

    # Is the ACL disabled?
    # @return [Boolean]
    def is_disabled?
      @disabled
    end

    # Disable the ACL
    def disable
      @disabled = true
    end

    # Enable the ACL
    def enable
      @disabled = false
    end

    # ACL can =========================================

    # Can the current user update this object?
    def can_update?
      !!@can.find {|x| x == "update"}
    end

    # Can the current user delete this object?
    def can_delete?
      !!@can.find {|x| x == "delete"}
    end

    # Can others? =====================================

    # Read permission for others
    # @return [Boolean]
    def can_others_read?
      @others[:read]
    end

    # Update permission for others
    # @return [Boolean]
    def can_others_update?
      @others[:update]
    end

    # Update permission for others
    # @return [Boolean]
    def can_others_delete?
      @others[:delete]
    end

    # Set others ======================================

    # Set read permission for others
    # @param [Boolean]
    def others_read(bool)
      @others[:read] = bool
    end

    # Set update permission for others
    # @param [Boolean]
    def others_update(bool)
      @others[:update] = bool
    end

    # Set delete permission for others
    # @param [Boolean]
    def others_delete(bool)
      @others[:delete] = bool
    end

    # Can users? ======================================

    # Get read permission for user
    def can_user_read?(user)
      can_user_op(user, :read)
    end

    # Get update permission for user
    def can_user_update?(user)
      can_user_op(user, :update)
    end

    # Get delete permission for user
    def can_user_delete?(user)
      can_user_op(user, :delete)
    end

    # Can roles? ======================================

    # Get read permission for role
    def can_role_read?(role)
      can_role_op(role, :read)
    end

    # Get update permission for role
    def can_role_update?(role)
      can_role_op(role, :update)
    end

    # Get delete permission for role
    def can_role_delete?(role)
      can_role_op(role, :delete)
    end

    # Set users =======================================

    # Set read permission for the user
    def user_read(user, bool)
      user_op(user, :read, bool)
    end

    # Set update permission for the user
    def user_update(user, bool)
      user_op(user, :update, bool)
    end

    # Set delete permission for the user
    def user_delete(user, bool)
      user_op(user, :delete, bool)
    end

    # Set roles =======================================

    # Set read permission for the role
    def role_read(role, bool)
      role_op(role, :read, bool)
    end

    # Set update permission for the role
    def role_update(role, bool)
      role_op(role, :update, bool)
    end

    # Set delete permission for the role
    def role_delete(role, bool)
      role_op(role, :delete, bool)
    end

    private

    def to_s
      "#<Built::ACL disabled=#{disabled}>"
    end

    def user_op(user, op, bool)
      elem_op(@users, user, op, bool)
    end

    def role_op(role, op, bool)
      elem_op(@roles, role, op, bool)
    end

    def elem_op(store, elem, op, bool)
      uid = elem.is_a?(String) ? elem : elem.uid

      if acl = store.find {|u| u == uid}
        acl[op] = bool
      else
        store << {:uid => uid, op => bool}
      end
    end

    def can_role_op(role, op)
      can_elem_op(@roles, role, op)
    end

    def can_user_op(user, op)
      uid = user.is_a?(String) ? user : user.uid
      return true if uid == @uid
      can_elem_op(@users, user, op)
    end

    def can_elem_op(store, elem, op)
      uid = elem.is_a?(String) ? elem : elem.uid
      acl = store.find {|u| u == uid} || {}
      acl[op] || false
    end
  end
end
