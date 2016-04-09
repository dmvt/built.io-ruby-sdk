# NOTE: A lot of this is pulled from the dirty_hashy gem. This was done to
# avoid the need for ActiveSupport and in recognition that it is no longer
# maintained.
#
# credit: https://github.com/archan937/dirty_hashy/blob/master/lib/dirty/hash.rb

module Built
  class BasicObject < Hash
    class << self
      def proxy_method(attr, writeable = false)
        define_method attr do
          self[attr]
        end

        if writeable
          define_method "#{attr}=" do |value|
            store(attr, value)
          end
        end
      end
    end

    proxy_method :created_at
    proxy_method :deleted_at
    proxy_method :updated_at

    def initialize(constructor = {})
      constructor.each { |key, value| self[key.to_sym] = value }
    end

    # Utility
    def replace(other)
      clear
      merge!(other) unless Util.blank?(other)
    end

    def change(key)
      key = key.to_sym
      changes[key] if changed?(key)
    end

    def changed?(key = :undefined)
      key == :undefined ? !changes.empty? : changes.key?(key.to_sym)
    end

    alias :dirty? :changed?

    def changes
      @changes ||= self.class.superclass.new
    end

    def clean_up!
      changes.clear
      nil
    end

    def clear
      keys.each { |key| delete(key) }
    end

    def delete(key)
      self[key.to_sym] = nil
      super
    end

    def [](key)
      super(key.to_sym)
    end

    def regular_writer(key, value)
      key = key.to_sym
      original_value = changes.key?(key) ? was(key) : fetch(key, nil)

      if original_value == value
        changes.delete(key)
      else
        changes[key] = [original_value, value]
      end

      _store(key, value)
    end

    alias_method :_store, :store
    alias_method :store, :regular_writer
    alias_method :[]=, :store

    def update(other)
      other.each { |key, value| store(key, value) }
    end

    def was(key)
      change(key).first if changed?(key)
    end
  end
end
