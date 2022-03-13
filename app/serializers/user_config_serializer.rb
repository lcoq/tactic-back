class UserConfigSerializer < ActiveModel::Serializer
  attributes :id, :type, :name, :description, :value
  has_one :user
end
