RSpec.describe Translatomatic::Translation::Fetcher do

  def self.notranslate(string = 'notranslate')
    '<span translate="no">' + string + '</span>'
  end

  def notranslate(string = 'notranslate')
    self.class.notranslate(string)
  end

  context '#translations' do
    # test case when number of notranslate tags coming back from the
    # translator is different to the number of tags that were sent.
    # this happened to me in a japanese translation.
    it 'handles mismatched preserved text count' do
      var1_wrapped = notranslate('{var1}')
      text = build_text('text {var1}', 'en')
      text.preserve_regex = /{.*?}/
      request_text = build_text("text #{var1_wrapped}", 'en')
      request_text.preserve_regex = text.preserve_regex
      result_text = "translated #{var1_wrapped} #{var1_wrapped}"

      # set up a translation that returns two wrapped {var1} texts
      # when we only sent one in the original text.
      mapping = { request_text => result_text }
      provider = TestProviderNoTranslate.new(mapping)

      fetcher = described_class.new(
        provider: provider, use_db: false,
        from_locale: 'en', to_locale: 'de', texts: [text]
      )
      translations = fetcher.translations
      puts translations.description
      expect(translations).to be_present
    end
  end

  # sample requests and responses from microsoft:
  # (note inconsistent spacing in responses)
  #
  #  request: hello <span translate="no">beer</span>
  # response: Hallo<span translate="no">beer</span>
  #
  #  request: hello <span translate="no">beer</span> wine
  # response: Hallo <span translate="no"> beer </span> Wein
  #
  #  request: <span translate="no">notranslate</span> hello
  # response: <span translate="no">notranslate</span>Hallo
  context 'removing notranslate directives from translation results' do
    TRANSLATIONS = [
      {
        original: 'hello notranslate',
        result: 'Hallo<span translate="no">notranslate</span>',
        wanted: 'Hallo notranslate'
      },
      {
        original: 'hello notranslate wine',
        result: 'Hallo <span translate="no"> notranslate </span> Wein',
        wanted: 'Hallo notranslate Wein'
      },
      {
        original: 'notranslate hello',
        result: '<span translate="no">notranslate</span>Hallo',
        wanted: 'notranslate Hallo'
      },
      # response where there is no changes in spacing required:
      {
        original: 'test notranslate hello',
        result: 'test <span translate="no">notranslate</span> Hallo',
        wanted: 'test notranslate Hallo'
      },
      # original with consecutive escapes
      {
        original: 'notranslate notranslate',
        result: notranslate + ' ' + notranslate,
        wanted: 'notranslate notranslate'
      },
      # original with no spaces
      {
        original: 'notranslatebeernotranslate',
        result: notranslate + 'Bier' + notranslate,
        wanted: 'notranslateBiernotranslate'
      },
      # sanity test: original without any notranslate text
      {
        original: 'hello',
        result: 'Hallo',
        wanted: 'Hallo'
      }
    ]
    TRANSLATIONS.each do |data|
      it "unwraps response '#{data[:result]}' to '#{data[:wanted]}'" do
        # set up provider and translation response
        provider = TestProviderNoTranslate.new
        source_text = build_text(data[:original], 'en')
        source_text.preserve_regex = /notranslate/
        result_text = build_text(data[:result], 'de')
        expect(provider).to receive(:translate).and_wrap_original { |m, *args|
          strings, from, to = *args
          result = Translatomatic::Translation::Result.new(
            strings[0], result_text, provider.name
          )
          [result]
        }

        # send request to fetcher to translate source_text
        fetcher = described_class.new(
          provider: provider, use_db: false,
          from_locale: 'en', to_locale: 'de', texts: [source_text]
        )

        # check that we got data[:wanted]
        tr_collection = fetcher.translations
        tr = tr_collection.get(source_text, 'de')        
        expect(tr).to be_present
        expect(tr.result.to_s).to eq(data[:wanted])
      end
    end
  end
end