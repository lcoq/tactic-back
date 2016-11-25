require 'test_helper'

describe UsersController do
  describe '#index' do
    it 'serialize the users' do
      create_user name: 'louis'
      create_user name: 'adrien'
      get '/users'
      assert_response :success
      response.body.must_equal serialized(User.all, UserSerializer)
    end
  end
end
