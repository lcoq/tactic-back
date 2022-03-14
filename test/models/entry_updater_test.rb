require 'test_helper'

describe EntryUpdater do
  subject { EntryUpdater }

  let(:falsy_updater) do
    Class.new do
      def self.use_for?(*args)
        false
      end
      def initialize(*args)
      end
    end
  end
  let(:truthy_updater) do
    Class.new do
      def self.use_for?(*args)
        true
      end
      def initialize(*args)
      end
    end
  end
  let(:truthy_updater_2) do
    Class.new do
      def self.use_for?(*args)
        true
      end
      def initialize(*args)
      end
    end
  end

  it 'classes are global entry updater classes' do
    assert_equal Globals.entry_updater_classes, subject.classes
  end
  it 'instantiate the first class having truthy #use_for?' do
    subject.stub :classes, [falsy_updater, truthy_updater, truthy_updater_2] do
      assert_instance_of truthy_updater, subject.for(:fake_args)
    end
  end
  it 'is nil without matching class' do
    subject.stub :classes, [falsy_updater] do
      assert_nil subject.for(:fake_args)
    end
  end
  it 'pass arguments to #use_for? and #new' do
    mock = Minitest::Mock.new
    mock.expect :use_for?, true, [:first_arg, :second_arg]
    mock.expect :new, nil, [:first_arg, :second_arg]
    subject.stub :classes, [mock] do
      subject.for :first_arg, :second_arg
    end
    mock.verify
  end
end
