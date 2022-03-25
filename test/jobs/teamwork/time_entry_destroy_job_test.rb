require 'test_helper'

describe Teamwork::TimeEntryDestroyJob do
  let(:user) { create_user(name: 'louis') }
  let(:entry) { create_entry(user: user) }
  let(:tactic_domain) do
    create_teamwork_domain({ user: user, name: 'tactic', alias: 'tc', token: 'tact-token' })
  end
  let(:time_entry) { create_teamwork_time_entry({ entry: entry, domain: tactic_domain, time_entry_id: 15243 }) }
  subject { Teamwork::TimeEntryDestroyJob }

  describe '#perform' do
    it 'does not raise with nonexistant time entry id' do
      subject.new(987654321).perform
    end
    it 'destroy the time entry' do
      mock = Minitest::Mock.new
      mock.expect :call, true, [time_entry]
      Teamwork::TimeEntrySynchronizer.stub :destroy_time_entry!, mock do
        subject.new(time_entry.id).perform
      end
      mock.verify
    end
  end

  it 'notify the user on failure' do
    now = Time.zone.now

    subject.new(
      time_entry.id,
      entry_title: "[tc/12345] My entry title",
      entry_duration: "01:35",
      entry_started_at: now
    ).failure(subject)

    notif = UserNotification.where(user: user).first
    assert notif
    assert_equal 'error', notif.nature
    refute_empty notif.message
    assert_match "My entry title", notif.message
    assert_match "01:35", notif.message
    assert_match "https://tactic.teamwork.com/#/tasks/12345", notif.message
  end
end
