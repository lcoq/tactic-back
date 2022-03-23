require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
# require "sprockets/railtie"
require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)

module TacticBack
  class Application < Rails::Application
    config.api_only = true
    config.time_zone = 'Paris'

    # Required for weird issue
    #   - https://github.com/rails/rails/issues/23589
    #   - https://github.com/collectiveidea/delayed_job_active_record/issues/128
    config.active_record.belongs_to_required_by_default = true

    config.active_record.schema_format = :sql
  end
end
