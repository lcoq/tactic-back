require 'test_helper.rb'

describe UserNotificationList do
  let(:user) { create_user(name: 'louis') }
  let(:before) { Time.zone.now }
  subject { UserNotificationList.new(user, before: before) }

  it 'includes user notifications before the given time' do
    yesterday_notif = create_user_notification(user: user)
    yesterday_notif.update_column :created_at, Time.zone.now - 1.day
    assert_includes subject.notifications, yesterday_notif
  end
  it 'does not include notifications after the given time' do
    tomorrow_notif = create_user_notification(user: user)
    tomorrow_notif.update_column :created_at, Time.zone.now + 1.day
    refute_includes subject.notifications, tomorrow_notif
  end
  it 'includes notifications at the given time' do
    notif = create_user_notification(user: user)
    notif.update_column :created_at, before
    assert_includes subject.notifications, notif
  end
  it 'id is the given time formatted' do
    assert_equal before.iso8601, subject.id
  end
  it 'errors are empty' do
    assert_empty subject.errors
  end
  it 'has user' do
    assert_equal user, subject.user
  end
  describe '#update_attributes' do
    it 'update all notifications attributes' do
      notifs = 3.times.map do
        notif = create_user_notification(user: user)
        notif.update_column :created_at, Time.zone.now - 1.day
        notif
      end
      assert subject.update_attributes(status: 'read')
      notifs.map(&:reload)
      assert notifs.all?(&:status_read?)
    end
    it 'does not update notifications on error' do
      notif = create_user_notification(user: user)
      notif.update_column :created_at, Time.zone.now - 1.day
      refute subject.update_attributes(status: 'invalid')
      refute notif.reload.status_read?
    end
    it 'has errors after update_attributes error' do
      notif = create_user_notification(user: user)
      notif.update_column :created_at, Time.zone.now - 1.day
      subject.update_attributes(status: 'invalid')
      refute_empty subject.errors
    end
  end

  describe 'Class methods' do
    subject { UserNotificationList }

    it '.latest uses the actual time' do
      now = Time.zone.now
      Time.zone.stub :now, now do
        assert_equal now, subject.latest(user).before
      end
    end
    it '.find_for_user uses the given time parsed' do
      now = Time.zone.now
      result = subject.find_for_user(user, now.iso8601)
      assert_equal now.iso8601, result.before.iso8601
    end
  end
end
