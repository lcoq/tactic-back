class ProjectSerializer < ActiveModel::Serializer
  attributes :id, :name
  has_one :client
end
