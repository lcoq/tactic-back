require 'test_helper'

describe Client do
  subject { build_client(name: "Client") }

  it 'is valid' do
    assert subject.valid?
  end
  it 'needs a name' do
    subject.name = nil
    refute subject.valid?
  end
  it 'name is unique' do
    subject.name = create_client(name: 'productivity').name
    refute subject.valid?
  end
  it 'name is unique case-insensitive' do
    subject.name = create_client(name: 'uniqueness-test').name.upcase
    refute subject.valid?
  end
  describe '#archive' do
    it 'archive and save the client' do
      assert subject.save
      subject.archive
      assert subject.reload.archived
    end
    it 'archive its projects' do
      assert subject.save
      project = create_project(name: 'Tactic', client: subject)
      subject.archive
      assert project.reload.archived
    end
  end
  describe '#destroy' do
    it 'clears its references on projects' do
      assert subject.save
      project = create_project(name: 'tactic', client: subject)
      subject.destroy
      refute project.reload.client_id
    end
  end
end
