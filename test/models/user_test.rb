require 'test_helper'

describe User do
  subject { build_user(name: 'louis', password: 'my-password') }

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
  it 'configs is a Hash' do
    assert subject.configs.kind_of?(Hash)
  end
  describe 'Password' do
    it 'needs a password on create' do
      subject = build_user(name: 'louis', password: nil)
      subject.password = nil
      refute subject.valid?
    end
    it 'password is optional for update' do
      save_user subject
      subject.password = nil
      assert subject.valid?
    end
    it 'password must have 8 characters' do
      subject.password = '1234567'
      refute subject.valid?
    end
    it 'password must have 8 characters for update' do
      save_user subject
      subject.password = '123'
      refute subject.valid?
    end
    it 'encrypted password is generated with a uniq salt' do
      ingrid = create_user(name: 'Ingrid', password: subject.password)
      save_user subject
      refute_equal subject.encrypted_password, ingrid.encrypted_password
    end
    it 'password is cleared on save' do
      save_user subject
      assert_nil subject.password
    end
    it 'password remains valid between saves' do
      save_user subject
      subject.name = 'Louis'
      save_user subject
      assert subject.authenticate('my-password')
    end
    it 'encrypted password and salt are cleared when the password changes' do
      save_user subject
      subject.password = 'newpassword'
      assert_nil subject.encrypted_password
      assert_nil subject.salt
    end
    it 'encrypted password and salt are not cleared when the password is set to nil' do
      save_user subject
      subject.password = nil
      refute_nil subject.encrypted_password
      refute_nil subject.salt
    end
  end
  it 'authenticates with valid password' do
    save_user subject
    assert subject.authenticate('my-password')
  end
  it 'does not authenticate with invalid password' do
    save_user subject
    refute subject.authenticate('invalid')
  end

  describe '#recent_entries' do
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
      assert_equal [ adrien, ingrid, louis ], subject.all
    end
  end
end
