require 'test_helper'

describe SessionsController do
  describe '#show' do
    it 'is forbidden with invalid Authorization header' do
      get '/sessions', headers: { 'Authorization' => 'invalid' }
      assert_response :forbidden
    end
    it 'retrieve and serialize the session from the Authorization header when valid' do
      session = build_session(user: create_user(name: 'louis'), token: 'session-token')
      assert session.save
      get '/sessions', headers: { 'Authorization' => 'session-token' }
      assert_response :success
      assert_equal serialized(session, SessionSerializer), response.body
    end
  end
  describe '#create' do
    let(:user) { create_user(name: 'louis', password: 'my-password') }
    let(:params) do
      {
        'data' => {
          'type' => 'session',
          'attributes' => {
            'password' => 'my-password'
          },
          'relationships' => {
            'user' => {
              'data' => {
                'type' => 'user',
                'id' => user.id.to_s
              }
            }
          }
        }
      }
    end

    it 'create a session and serialize it' do
      post '/sessions', params: params
      assert_response :success
      session = Session.find_by(user: user)
      assert session.present?
      assert_equal serialized(session, SessionSerializer), response.body
    end
    it 'does not create a session with invalid password' do
      params['data']['attributes']['password'] = 'invalid'
      post '/sessions', params: params
      assert_response :unprocessable_entity
      body = JSON.parse(response.body)
      refute body['errors'].empty?
    end
    it 'does not create a session without user' do
      params['data']['relationships'].delete 'user'
      post '/sessions', params: params
      assert_response :unprocessable_entity
      body = JSON.parse(response.body)
      refute body['errors'].empty?
    end
  end
end
