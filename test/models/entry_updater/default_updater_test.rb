describe EntryUpdater::DefaultUpdater do
  let(:user) { create_user(name: 'louis') }
  let(:entry) { create_entry(user: user) }
  subject { EntryUpdater::DefaultUpdater.new(entry, :foo) }

  describe '#update' do
    it 'succeeds' do
      new_title = "New entry title"
      assert subject.update(title: new_title)
    end
    it 'fails' do
      refute subject.update(user: nil)
    end
    it 'changes entry attributes' do
      new_title = "New entry title"
      subject.update title: new_title
      assert_equal new_title, entry.title
    end
    it 'persists valid updates' do
      new_title = "New entry title"
      subject.update title: new_title
      assert_equal new_title, entry.reload.title
    end
    it 'does not persist invalid updates' do
      subject.update user: nil
      assert_equal user, entry.reload.user
    end
  end

  describe '#destroy' do
    it 'succeeds' do
      assert subject.destroy
    end
    it 'persists destroy' do
      subject.destroy
      assert_nil Entry.find_by(id: entry.id)
    end
  end
end
