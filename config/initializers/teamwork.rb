Rails.application.config.to_prepare do
  ::User.include Teamwork::HasManyDomains

  Globals.register_user_config_definition(
    name: 'teamwork',
    type: :boolean,
    description: "Enable to activate Teamwork integration"
  )
end
