require 'test_helper'

describe SessionsController do
  describe '#create' do
    let(:user) { create_user(name: 'louis') }
    let(:params) do
      {
        'data' => {
          'type' => 'session',
          'attributes' => {},
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
      response.body.must_equal serialized(session, SessionSerializer)
    end
    it 'does not create a session without user' do
      post '/sessions', params: { 'data' => { 'type' => 'session', 'attributes' => {}, 'relationships' => {} } }
      assert_response :unprocessable_entity
      body = JSON.parse(response.body)
      refute body['errors'].empty?
    end
  end
end
