require 'test_helper'

describe Teamwork::TimeEntrySynchronizeJob do
  let(:user) { create_user(name: 'louis') }
  let(:entry) { create_entry(user: user) }
  subject { Teamwork::TimeEntrySynchronizeJob }

  describe '#perform' do
    it 'does not raise with nonexistant entry id' do
      subject.new(987654321, user.id).perform
    end
    it 'does not raise with nonexistant user id' do
      subject.new(entry.id, 987654321).perform
    end
    it 'synchronize the time entry' do
      mock = Minitest::Mock.new
      mock.expect :call, true, [entry, {user: user}]
      Teamwork::TimeEntrySynchronizer.stub :synchronize!, mock do
        subject.new(entry.id, user.id).perform
      end
      mock.verify
    end
  end

  it 'notify the user on failure'
end
