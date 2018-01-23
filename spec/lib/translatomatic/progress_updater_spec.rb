RSpec.describe Translatomatic::ProgressUpdater do

  it 'creates a progress updater' do
    progressbar = double(:progressbar)
    updater = described_class.new(progressbar)
    expect(updater).to be
  end

  it 'increments progress bar progress when texts are translated' do
    progressbar = double(:progressbar)
    progress = double(:progress)
    allow(progressbar).to receive(:progress).and_return(progress)
    #expect(progress).to receive(:"+=").with(2)
    expect(progress).to receive(:+).with(2).and_return(progress)
    expect(progressbar).to receive(:progress=)
    updater = described_class.new(progressbar)
    updater.processed_strings(2)
  end

end
