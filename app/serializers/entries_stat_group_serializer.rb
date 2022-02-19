class EntriesStatGroupSerializer < ActiveModel::Serializer
  attributes :id,
             :title,
             :nature

  has_many :entries_stats

end
