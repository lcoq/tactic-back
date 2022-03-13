module Teamwork
  class DomainSerializer < ActiveModel::Serializer
    type 'teamwork/domains'
    attributes :id, :name, :alias, :token
  end
end
