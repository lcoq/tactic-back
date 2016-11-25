class SessionSerializer < ActiveModel::Serializer
  attributes :id, :token, :name
end
