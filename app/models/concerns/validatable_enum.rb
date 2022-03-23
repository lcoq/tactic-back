module ValidatableEnum
  extend ActiveSupport::Concern

  class_methods do
    def validatable_enum(attribute)
      block = ->(subtype) do
        ValidatableEnumType.new(attribute, public_send(attribute.to_s.pluralize), subtype)
      end
      if method(:decorate_attribute_type).parameters.count == 2
        decorate_attribute_type(attribute, &block)
      else
        decorate_attribute_type(attribute, :enum, &block)
      end
    end
  end
end
