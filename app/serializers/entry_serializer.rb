class EntrySerializer < ActiveModel::Serializer
  attributes :id,
             :title,
             :started_at,
             :stopped_at,
             :rounded_started_at,
             :rounded_stopped_at,
             :rounded_duration

  has_one :project
  has_one :user
end
