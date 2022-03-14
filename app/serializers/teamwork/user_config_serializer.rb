module Teamwork
  class UserConfigSerializer < ActiveModel::Serializer
    type 'teamwork/user-configs'
    attributes :id, :name, :description, :value
    has_one :user
  end
end
