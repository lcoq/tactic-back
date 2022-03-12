require 'test_helper'

describe UsersController do
  let(:user) { create_user(name: 'louis') }
  let(:session) { build_session(user: user).tap { |s| assert s.save } }
  let(:headers) { { 'Authorization' => session.token } }

  describe '#index' do
    it 'serialize the users ordered by name' do
      users = [
        create_user(name: 'adrien'),
        create_user(name: 'louis'),
        create_user(name: 'ingrid')
      ]
      get '/users'
      assert_response :success
      assert_equal serialized(users.sort_by(&:name), UserSerializer), response.body
    end
  end

  describe '#show' do
    it 'is forbidden with invalid Authorization header' do
      get "/users/#{user.id}", headers: { 'Authorization' => 'invalid' }
      assert_response :forbidden
    end
    it 'is forbidden when the user is not the current' do
      other_user = create_user(name: 'adrien')
      get "/users/#{other_user.id}", headers: headers
      assert_response :forbidden
    end
    it 'serializes the user' do
      get "/users/#{user.id}", headers: headers
      assert_response :success
      assert_equal serialized(user, UserSerializer), response.body
    end
  end

  describe '#update' do
    let(:params) do
      {
        'data' => {
          'type' => 'users',
          'attributes' => {
            'name' => 'louis 2',
            'password' => 'my-new-password'
          }
        }
      }
    end

    it 'is forbidden with invalid Authorization header' do
      patch "/users/#{user.id}", headers: { 'Authorization' => 'invalid' }, params: params
      assert_response :forbidden
    end
    it 'is forbidden when the user is not the current' do
      other_user = create_user(name: 'adrien')
      patch "/users/#{other_user.id}", headers: headers, params: params
      assert_response :forbidden
    end
    it 'updates the current user' do
      patch "/users/#{user.id}", headers: headers, params: params
      assert_response :success
      user.reload
      assert_equal 'louis 2', user.name
      assert user.authenticate('my-new-password')
    end
    it 'serializes the current user' do
      patch "/users/#{user.id}", headers: headers, params: params
      assert_response :success
      assert_equal serialized(user.reload, UserSerializer), response.body
    end
    describe 'With invalid params' do
      before do
        params['data']['attributes']['name'] = nil
      end
      it 'does not update the user' do
        patch "/users/#{user.id}", headers: headers, params: params
        assert_response :unprocessable_entity
      end
      it 'serialize the errors' do
        patch "/users/#{user.id}", headers: headers, params: params
        assert_response :unprocessable_entity
        parsed = JSON.parse(response.body)
        refute_empty parsed['errors']
        assert parsed['errors'].any? { | error| error['source']['pointer'] == '/data/attributes/name' }
      end
    end
  end
end
