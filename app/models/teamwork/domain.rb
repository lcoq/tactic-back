class Teamwork::Domain < ApplicationRecord
  belongs_to :user

  validates :name, presence: true
  validates :name, uniqueness: { scope: :user }
  validates :alias, presence: true
  validates :alias, uniqueness: { scope: :user }
  validates :token, presence: true
end
