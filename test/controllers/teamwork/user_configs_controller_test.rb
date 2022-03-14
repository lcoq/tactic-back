require 'test_helper'

describe Teamwork::UserConfigsController do
  let(:user) { create_user(name: 'louis') }
  let(:session) { build_session(user: user).tap { |s| assert s.save } }
  let(:headers) { { 'Authorization' => session.token } }

  describe '#index' do
    it 'is forbidden with invalid Authorization header' do
      get "/teamwork/configs", headers: { 'Authorization' => 'invalid' }
      assert_response :forbidden
    end
    it 'serializes current user configs' do
      get "/teamwork/configs", headers: headers
      assert_response :success
      assert_equal serialized(Teamwork::UserConfig.list_for_user(user), Teamwork::UserConfigSerializer), response.body
    end
  end

  describe '#update' do
    let(:config) { Teamwork::UserConfig.list_for_user(user).first }
    let(:params) do
      {
        'data' => {
          'type' => 'teamwork/user-configs',
          'attributes' => {
            'value' => true
          }
        }
      }
    end
    it 'is forbidden with invalid Authorization header' do
      patch "/teamwork/configs/#{config.id}", headers: { 'Authorization' => 'invalid' }, params: params
      assert_response :forbidden
    end
    it 'updates the config' do
      patch "/teamwork/configs/#{config.id}", headers: headers, params: params, as: :json
      assert_response :success
      user.reload
      assert_equal true, Teamwork::UserConfig.find_for_user(user, config.id).value
    end
    it 'serializes the config' do
      patch "/teamwork/configs/#{config.id}", headers: headers, params: params, as: :json
      assert_response :success
      user.reload
      assert_equal serialized(Teamwork::UserConfig.find_for_user(user, config.id), Teamwork::UserConfigSerializer), response.body
    end
    describe 'With invalid params' do
      before do
        params['data']['attributes']['value'] = 'string-instead-of-boolean'
      end
      it 'does not update the config' do
        patch "/teamwork/configs/#{config.id}", headers: headers, params: params, as: :json
        assert_response :unprocessable_entity
        parsed = JSON.parse(response.body)
        refute_empty parsed['errors']
        assert parsed['errors'].any? { | error| error['source']['pointer'] == '/data/attributes/value' }
      end
    end
  end
end
