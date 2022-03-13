class UserConfig
  extend ActiveModel::Naming
  include ActiveModel::Serialization

  TRANSFORMS = {
    boolean: {
      serialize: ->(raw) { raw || nil },
      deserialize: ->(serialized) { !!serialized }
    }
  }

  def self.list_for_user(user)
    Globals.user_config_definitions.map do |definition|
      new user, definition
    end
  end

  def self.find_for_user(user, id)
    list_for_user(user).detect { |d| d.id == id }
  end

  attr_reader :user,
              :definition

  def initialize(user, definition)
    @user = user
    @definition = definition
    @transform = find_transform
  end

  def id
    name.parameterize
  end

  def name
    definition[:name]
  end

  def type
    definition[:type]
  end

  def description
    definition[:description]
  end

  def value
    serialized = read_user_config
    transform[:deserialize].call serialized
  end

  def update_value(raw)
    new_value = transform[:serialize].call(raw)
    write_user_config new_value
  end

  def attributes
    {
      name: name,
      type: type,
      value: value,
      description: description
    }
  end

  private

  attr_reader :transform

  def find_transform
    TRANSFORMS[type]
  end

  def read_user_config
    user.configs[id]
  end

  def write_user_config(new_value)
    new_configs = user.configs.merge(id => new_value).compact
    user.update_attribute :configs, new_configs
  end

end
