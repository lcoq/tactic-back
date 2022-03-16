class Teamwork::TimeEntry < ApplicationRecord
  belongs_to :entry
  belongs_to :domain, class_name: 'Teamwork::Domain', foreign_key: 'teamwork_domain_id'

  validates :entry_id, uniqueness: true
  validates :time_entry_id, presence: true
  validates :time_entry_id, uniqueness: true

  def domain_id
    teamwork_domain_id
  end

  def domain_id=(new_value)
    self.teamwork_domain_id = new_value
  end
end
