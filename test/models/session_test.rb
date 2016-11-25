require 'test_helper'

describe Session do
  let(:user) { create_user(name: 'louis') }
  subject { build_session(user: user) }

  it 'is valid' do
    assert subject.valid?
  end
  it 'needs a token' do
    subject.token = nil
    refute subject.valid?
  end
  it 'token is unique' do
    subject.token = create_session(user: create_user(name: 'adrien')).token
    refute subject.valid?
  end
  it 'needs a user' do
    subject.user = nil
    refute subject.valid?
  end
  it 'name is the user name' do
    assert_equal user.name, subject.name
  end

  describe 'Class methods' do
    subject { Session }

    describe '#new_with_generated_token' do
      it 'is a new session' do
        session = subject.new_with_generated_token
        assert session.is_a?(Session)
      end
      it 'generates a token' do
        session = subject.new_with_generated_token
        assert session.token.present?
      end
      it 'assigns attributes' do
        user = create_user(name: 'louis')
        session = subject.new_with_generated_token(user: user)
        assert_equal user, session.user
      end
    end
  end
end
