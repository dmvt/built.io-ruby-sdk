module Built
  module Instantiate
    module ClassMethods
      def instantiate(data)
        new(data)
      end
    end

    module InstanceMethods
      def instantiate(data)
        replace(data)
        clean_up!
        self
      end
    end

    def self.included(descendent)
      descendent.send(:extend, ClassMethods)
      descendent.send(:include, InstanceMethods)
    end
  end
end
