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
  describe '#destroy' do
    it 'clears its references on projects' do
      assert subject.save
      project = create_project(name: 'tactic', client: subject)
      subject.destroy
      refute project.reload.client_id
    end
  end
end
