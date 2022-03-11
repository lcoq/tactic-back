module Teamwork
  module HasManyDomains
    extend ActiveSupport::Concern
    included do
      has_many :teamwork_domains, class_name: 'Teamwork::Domain', dependent: :destroy
    end
  end
end
