module HiddenSingleton
  extend ActiveSupport::Concern

  included do
    include Singleton
    private_class_method :instance
  end

  module ClassMethods
    def method_missing(method, *args, &block)
      return super unless instance.respond_to?(method)
      instance.send method, *args, &block
    end
  end

end
