require 'test_helper'

describe User do
  subject { build_user(name: 'louis') }

  it 'is valid' do
    assert subject.valid?
  end
  it 'needs a name' do
    subject.name = nil
    refute subject.valid?
  end
  it 'name is unique' do
    subject.name = create_user(name: 'uniqueness-test').name
    refute subject.valid?
  end
  it 'name is unique case-insensitive' do
    subject.name = create_user(name: 'uniqueness-test').name.upcase
    refute subject.valid?
  end
  describe 'recent_entries' do
    before { assert subject.save }
    it 'has last month entries' do
      entries = 2.times.map do
        create_entry(
          user: subject,
          started_at: Time.zone.now - 1.month + 1.day,
          stopped_at: Time.zone.now - 1.month + 1.day + 2.hours
        )
      end
      assert_equal entries, subject.recent_entries
    end
    it 'does not have entries older than a month' do
      entries = 2.times.map do
        create_entry(
          user: subject,
          started_at: Time.zone.now - 1.month - 1.day,
          stopped_at: Time.zone.now - 1.month - 1.day + 2.hours,
        )
      end
      assert_equal [], subject.recent_entries
    end
  end
  describe '#running_entry' do
    before { assert subject.save }
    it 'nil without running entry' do
      refute subject.running_entry
    end
    it 'is the running entry' do
      running = create_entry(user: subject, stopped_at: nil)
      assert_equal running, subject.running_entry
    end
  end
  describe '#destroy' do
    it 'destroys its sessions on destroy' do
      assert subject.save
      session = create_session(user: subject, token: "token")
      subject.destroy
      assert_raises(ActiveRecord::RecordNotFound) { session.reload }
    end
    it 'destroys its entries on destroy' do
      assert subject.save
      entry = create_entry(user: subject)
      subject.destroy
      assert_raises(ActiveRecord::RecordNotFound) { entry.reload }
    end
  end

  describe 'Class methods' do
    subject { User }

    it 'default scope orders alphabetically' do
      louis = create_user(name: 'louis')
      adrien = create_user(name: 'adrien')
      ingrid = create_user(name: 'ingrid')
      subject.all.must_equal [ adrien, ingrid, louis ]
    end
  end
end
