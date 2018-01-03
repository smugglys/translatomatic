RSpec.describe Translatomatic::Translator::Base do

  class DummyTranslator < Translatomatic::Translator::Base

    ERROR_MESSAGE = "translation error"

    attr_accessor :raise_error_count
    attr_accessor :use_perform_fetch_translations
    attr_reader :fetch_count

    def perform_translate(strings, from, to)
      if use_perform_fetch_translations
        uri = URI.parse("http://www.example.com")
        perform_fetch_translations(uri, strings, from, to)
      else
        return ["Result"]
      end
    end

    def fetch_translation(request, strings, from, to)
      @errors ||= 0
      @fetch_count ||= 0
      @fetch_count += 1
      if raise_error_count && @errors < raise_error_count
        @errors += 1
        raise ERROR_MESSAGE
      end

      return ["Result"]
    end

  end

  context :languages do
    it "returns an empty language list by default" do
      t = DummyTranslator.new
      expect(t.languages).to be_empty
    end
  end

  context :name do
    it "returns the translator name" do
      t = DummyTranslator.new
      expect(t.name).to eq(DummyTranslator.to_s)
    end
  end

  context :perform_fetch_translations do
    it "retries 3 times on error" do
      t = DummyTranslator.new
      t.raise_error_count = 2
      t.use_perform_fetch_translations = true
      expect {
        t.translate("String", "en", "de")
      }.to_not raise_error
    end

    it "stops after failing 3 times" do
      t = DummyTranslator.new
      t.raise_error_count = 3
      t.use_perform_fetch_translations = true
      expect {
        t.translate("String", "en", "de")
      }.to raise_error(DummyTranslator::ERROR_MESSAGE)
      expect(t.fetch_count).to eq(3)
    end
  end

end
