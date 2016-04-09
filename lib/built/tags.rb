module Built
  module Tags
    # Get tags for this upload
    def tags
      self[:tags] || []
    end

    # Add new tags
    # @param [Array] tags An array of strings. Can also be a single tag.
    # @return [Object] self
    def add_tags(tags)
      tags = tags.is_a?(Array) ? tags : [tags]
      self[:tags] ||= []
      self[:tags].concat(tags)
      self
    end

    # Remove tags
    # @param [Array] tags An array of strings. Can also be a single tag.
    # @return [Object] self
    def remove_tags(tags)
      tags = tags.is_a?(Array) ? tags : [tags]
      self[:tags] ||= []
      self[:tags] = self[:tags] - tags
      self
    end
  end
end
