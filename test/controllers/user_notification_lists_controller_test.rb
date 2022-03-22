require 'test_helper'

describe UserNotificationListsController do
  let(:user) { create_user(name: 'louis') }
  let(:session) { build_session(user: user).tap { |s| assert s.save } }
  let(:headers) { { 'Authorization' => session.token } }

  describe '#latest' do
    it 'is forbidden with invalid Authorization header' do
      get "/users/#{user.id}/notification_lists/latest", headers: { 'Authorization' => 'invalid' }
      assert_response :forbidden
    end
    it 'is forbidden when the user is not the current' do
      other_user = create_user(name: 'adrien')
      get "/users/#{other_user.id}/notification_lists/latest", headers: headers
      assert_response :forbidden
    end
    it 'serializes the list' do
      notif = create_user_notification({ user: user })
      notif.update_column :created_at, Time.zone.now - 1.day
      now = Time.zone.now
      Time.zone.stub :now, now do
        get "/users/#{user.id}/notification_lists/latest", headers: headers
      end
      assert_response :success

      list = UserNotificationList.find_for_user(user, now.iso8601)
      assert_equal serialized(list, UserNotificationListSerializer), response.body
    end
    it 'includes notifications and notifications resource' do
      entry = create_entry({ user: user })
      notif = create_user_notification({ user: user, resource: entry })
      notif.update_column :created_at, Time.zone.now - 1.day

      now = Time.zone.now
      Time.zone.stub :now, now do
        get "/users/#{user.id}/notification_lists/latest", headers: headers, params: { 'include' => 'notifications,notifications.resource' }
      end
      assert_response :success
      assert_equal serialized(UserNotificationList.find_for_user(user, now.iso8601), UserNotificationListSerializer, include: ['notifications', 'notifications.resource']), response.body
    end
  end

  describe '#update' do
    let(:list) { UserNotificationList.latest(user) }
    let(:id) { list.id }
    let(:params) do
      {
        'data' => {
          'type' => 'user-notification-lists',
          'attributes' => {
            'status' => 'read'
          }
        }
      }
    end

    it 'is forbidden with invalid Authorization header' do
      patch "/users/#{user.id}/notification_lists/#{id}", headers: { 'Authorization' => 'invalid' }, params: params
      assert_response :forbidden
    end
    it 'is forbidden when the user is not the current' do
      other_user = create_user(name: 'adrien')
      patch "/users/#{other_user.id}/notification_lists/#{id}", headers: headers, params: params
      assert_response :forbidden
    end
    it 'updates notifications' do
      notif = create_user_notification(user: user, status: :unread)
      notif.update_column :created_at, Time.zone.now - 1.day
      patch "/users/#{user.id}/notification_lists/#{id}", headers: headers, params: params
      assert_response :success
      notif.reload
      assert notif.status_read?
    end
    it 'serializes the list with notifications' do
      notif = create_user_notification(user: user, status: :unread)
      notif.update_column :created_at, Time.zone.now - 1.day
      patch "/users/#{user.id}/notification_lists/#{id}", headers: headers, params: params
      assert_response :success
      assert_equal serialized(list, UserNotificationListSerializer, include: 'notifications'), response.body
    end
    describe 'With invalid params' do
      before do
        params['data']['attributes']['status'] = 'invalid'
      end
      it 'unprocessable entity' do
        notif = create_user_notification(user: user, status: :unread)
        notif.update_column :created_at, Time.zone.now - 1.day
        patch "/users/#{user.id}/notification_lists/#{id}", headers: headers, params: params
        assert_response :unprocessable_entity
        parsed = JSON.parse(response.body)
        refute_empty parsed['errors']
        assert parsed['errors'].any? { | error| error['source']['pointer'] == '/data/attributes/status' }
      end
    end
  end
end
