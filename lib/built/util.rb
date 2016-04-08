require "inflecto"

module Built
  class Util
    include Inflecto

    class << self
      def blank?(value)
        value.respond_to?(:empty?) ? value.empty? : !value
      end

      def type_check(key, value, type)
        unless value.is_a?(type)
          raise BuiltError, I18n.t("datatypes.not_match", {
            :key => key,
            :type => type
          })
        end
      end

      def is_i?(value)
        !!(value =~ /^[-+]?[0-9]+$/)
      end
    end
  end
end
