module Teamwork
  module UserExtension
    extend ActiveSupport::Concern
    included do
      has_many :teamwork_domains, class_name: 'Teamwork::Domain', dependent: :destroy
      has_many :teamwork_user_config_sets, class_name: 'Teamwork::UserConfigSet', dependent: :destroy
    end
  end
end
