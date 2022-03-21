class UserNotificationListSerializer < ActiveModel::Serializer
  attributes :id
  has_one :user
  has_many :notifications
end
