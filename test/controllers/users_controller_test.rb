require 'test_helper'

describe UsersController do
  describe '#index' do
    it 'serialize the users ordered by name' do
      users = [
        create_user(name: 'adrien'),
        create_user(name: 'louis'),
        create_user(name: 'ingrid')
      ]
      get '/users'
      assert_response :success
      response.body.must_equal serialized(users.sort_by(&:name), UserSerializer)
    end
  end
end
