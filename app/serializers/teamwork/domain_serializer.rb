module Teamwork
  class DomainSerializer < ActiveModel::Serializer
    attributes :id, :name, :alias, :token
  end
end
