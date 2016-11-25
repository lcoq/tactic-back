class EntrySerializer < ActiveModel::Serializer
  attributes :id, :title, :started_at, :stopped_at
end
