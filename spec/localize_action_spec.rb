describe Fastlane::Actions::LocalizeAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The localize plugin is working!")

      Fastlane::Actions::LocalizeAction.run(nil)
    end
  end
end
