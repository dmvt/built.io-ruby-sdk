module Built
  class Util
    def self.blank?(value)
      value.respond_to?(:empty?) ? value.empty? : !value
    end
  end
end