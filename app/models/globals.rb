class Globals

  include HiddenSingleton

  attr_reader :user_config_definitions

  def initialize
    @user_config_definitions = Set.new
  end

  def register_user_config_definition(definition)
    user_config_definitions << definition
  end

  register_user_config_definition(
    name: 'summary rounding',
    type: :boolean,
    description: "Enable to round entries durations by default on weekly and monthly summaries"
  )
  register_user_config_definition(
    name: 'reviews rounding',
    type: :boolean,
    description: "Enable to round entries durations by default on reviews page"
  )
end
