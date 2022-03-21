class UserNotificationSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :nature, :status, :title, :message
  has_one :user
  has_one :resource
end
