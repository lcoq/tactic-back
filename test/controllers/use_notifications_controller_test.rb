require 'test_helper'

describe UserNotificationListsController do
  let(:user) { create_user(name: 'louis') }
  let(:session) { build_session(user: user).tap { |s| assert s.save } }
  let(:headers) { { 'Authorization' => session.token } }
  let(:notification) { create_user_notification(user: user) }

  describe '#destroy' do
    it 'is forbidden with invalid Authorization header' do
      delete "/users/#{user.id}/notifications/#{notification.id}", headers: { 'Authorization' => 'invalid' }
      assert_response :forbidden
    end
    it 'is forbidden when the user is not the current' do
      other_user = create_user(name: 'adrien')
      other_notification = create_user_notification(user: other_user)
      delete "/users/#{other_user.id}/notifications/#{notification.id}", headers: { 'Authorization' => 'invalid' }
      assert_response :forbidden
    end
    it 'destroys the notification' do
      delete "/users/#{user.id}/notifications/#{notification.id}", headers: headers
      assert_response :no_content
      assert_raises(ActiveRecord::RecordNotFound) { notification.reload }
    end
  end
end
