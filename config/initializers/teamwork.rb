Rails.application.config.to_prepare do
  ::User.include Teamwork::UserExtension

  Globals.register_user_config_definition(
    name: 'teamwork',
    type: :boolean,
    description: "Enable to activate Teamwork integration"
  )

  Globals.register_entry_updater_class Teamwork::EntryUpdater
end
