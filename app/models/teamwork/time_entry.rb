class Teamwork::TimeEntry < ApplicationRecord
  belongs_to :entry

  validates :entry_id, uniqueness: true
  validates :time_entry_id, presence: true
  validates :time_entry_id, uniqueness: true
end
