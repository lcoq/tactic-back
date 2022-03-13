class UserSerializer < ActiveModel::Serializer
  attributes :id, :name
  has_many :configs

  def configs
    UserConfig.list_for_user(object)
  end
end
