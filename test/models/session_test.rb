require 'test_helper'

describe Session do
  let(:user) { create_user(name: 'louis', password: 'my-password') }
  subject { build_session(user: user, password: 'my-password') }

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
  it 'needs a password' do
    subject.password = nil
    refute subject.valid?
  end
  it 'password must match the user password' do
    subject.password = 'invalid'
    refute subject.valid?
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
