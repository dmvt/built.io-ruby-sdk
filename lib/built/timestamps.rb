module Built
  module Timestamps
    def created_at
      DateTime.parse self["created_at"]
    end

    def updated_at
      DateTime.parse self["updated_at"]
    end

    def deleted_at
      DateTime.parse self["deleted_at"]
    end
  end
end