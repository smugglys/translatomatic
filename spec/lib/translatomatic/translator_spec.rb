RSpec.describe Translatomatic::Provider do
  describe :available do
    it 'should find all available providers' do
      list = Translatomatic::Provider.available
      expect(list).to be
    end
  end
end
