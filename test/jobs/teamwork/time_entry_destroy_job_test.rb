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

  it 'notify the user on failure'
end
