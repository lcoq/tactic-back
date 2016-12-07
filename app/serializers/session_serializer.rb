class SessionSerializer < ActiveModel::Serializer
  attributes :id, :token, :name
  has_one :user
end
