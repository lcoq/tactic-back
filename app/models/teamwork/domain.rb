class Teamwork::Domain < ApplicationRecord
  belongs_to :user
  has_many :time_entries, dependent: :destroy, foreign_key: 'teamwork_domain_id'

  before_validation :set_alias_to_name

  validates :name, presence: true
  validates :name, uniqueness: { scope: :user }
  validates :alias, presence: true
  validates :alias, uniqueness: { scope: :user }
  validates :token, presence: true

  private

  def set_alias_to_name
    if self.alias.blank?
      self.alias = name
    end
  end
end
