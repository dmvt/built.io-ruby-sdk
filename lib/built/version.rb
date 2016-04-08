module Built
  VERSION_INFO = [0, 9, 0] unless defined?(self::VERSION_INFO)
  VERSION = VERSION_INFO.map(&:to_s).join('.') unless defined?(self::VERSION)

  def self.version
    VERSION
  end
end
