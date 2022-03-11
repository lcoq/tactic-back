Rails.application.config.to_prepare do
  ::User.include Teamwork::HasManyDomains
end
