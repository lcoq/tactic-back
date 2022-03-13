require 'test_helper'

describe UserConfigsController do
  let(:user) { create_user(name: 'louis') }
  let(:session) { build_session(user: user).tap { |s| assert s.save } }
  let(:headers) { { 'Authorization' => session.token } }

  describe '#index' do
    it 'is forbidden with invalid Authorization header' do
      get "/users/#{user.id}/configs", headers: { 'Authorization' => 'invalid' }
      assert_response :forbidden
    end
    it 'is forbidden when the user is not the current' do
      other_user = create_user(name: 'adrien')
      get "/users/#{other_user.id}/configs", headers: headers
      assert_response :forbidden
    end
    it 'serializes current user configs' do
      get "/users/#{user.id}/configs", headers: headers
      assert_response :success
      assert_equal serialized(UserConfig.list_for_user(user), UserConfigSerializer), response.body
    end
  end

  describe '#update' do
    let(:config) { UserConfig.list_for_user(user).first }
    let(:params) do
      {
        'data' => {
          'type' => 'user-configs',
          'attributes' => {
            'value' => true
          }
        }
      }
    end
    it 'is forbidden with invalid Authorization header' do
      patch "/users/#{user.id}/configs/#{config.id}", headers: { 'Authorization' => 'invalid' }, params: params
      assert_response :forbidden
    end
    it 'is forbidden when the user is not the current' do
      other_user = create_user(name: 'adrien')
      patch "/users/#{other_user.id}/configs/#{config.id}", headers: headers, params: params
      assert_response :forbidden
    end
    it 'updates the config' do
      patch "/users/#{user.id}/configs/#{config.id}", headers: headers, params: params, as: :json
      assert_response :success
      user.reload
      assert_equal true, UserConfig.find_for_user(user, config.id).value
    end
    it 'serializes the config' do
      patch "/users/#{user.id}/configs/#{config.id}", headers: headers, params: params, as: :json
      assert_response :success
      user.reload
      assert_equal serialized(UserConfig.find_for_user(user, config.id), UserConfigSerializer), response.body
    end
  end
end
