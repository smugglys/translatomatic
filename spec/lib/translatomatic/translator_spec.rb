RSpec.describe Translatomatic::Translator do
  before(:all) do
    @mapping = {}
  end
  before(:each) do
    @mapping.clear
  end

  let(:provider) { TestProvider.new(@mapping) }
  let(:unused_provider) {
    prov = TestProvider.new
    expect(prov).to_not receive(:translate)
    prov
  }

  describe '#new' do
    it 'should create a translator instance' do
      translator = create_translator
      expect(translator).to be
    end
  end

  describe '#translate' do
    it 'translates a single string' do
      string = build_text('hello', 'en')

      setup_translation('hello', 'hallo')
      translation = default_translator.translate(string, 'de')

      expect_translation(translation, string, 'hallo', 'de')
    end

    it 'translates two strings' do
      string1 = build_text('left', 'en')
      string2 = build_text('right', 'en')

      setup_translation('left', 'links')
      setup_translation('right', 'rechts')
      translation = default_translator.translate([string1, string2], 'de')

      expect_translation(translation, string1, 'links', 'de')
      expect_translation(translation, string2, 'rechts', 'de')
    end

    it 'translates a string with a context' do
      string = build_text('right', 'en')
      string.context = 'go right'

      setup_translation('right', ['richtig', 'rechts', 'Recht'])
      setup_translation('go right', 'Geh rechts')
      translation = default_translator.translate(string, 'de')

      expect_translation(translation, string, 'rechts', 'de')
    end

    # test translating two identical strings with different contexts
    it 'translates two identical strings with different contexts' do
      string1 = build_text('right', 'en', context: 'go right')
      string2 = build_text('right', 'en', context: 'you are right')

      setup_translation('right', ['richtig', 'rechts', 'Recht'])
      setup_translation('go right', 'Geh rechts')
      setup_translation('you are right', 'Du hast recht')
      translation = default_translator.translate([string1, string2], 'de')

      expect_translation(translation, string1, 'rechts', 'de')
      expect_translation(translation, string2, 'Recht', 'de')
    end

    it 'translates a string with two sentences' do
      string = build_text('Sentence one. Sentence two.', 'en')

      setup_translation('Sentence one.', 'Satz eins.')
      setup_translation('Sentence two.', 'Satz zwei.')
      translation = default_translator.translate(string, 'de')

      expect_translation(translation, string, 'Satz eins. Satz zwei.', 'de')
    end

    it 'translates a string with repeated sentences' do
      string = build_text('Sentence. Sentence.', 'en')

      setup_translation('Sentence.', 'Satz.')
      translation = default_translator.translate(string, 'de')

      expect_translation(translation, string, 'Satz. Satz.', 'de')
    end

    it 'preserves variables' do
      string = build_text("rah {var} rah", 'en')
      string.preserve_regex = /\{.*?\}/
      setup_translation(string, 'zomg {translated_var} zomg')
      translation = default_translator.translate(string, 'de')

      expect_translation(translation, string, 'zomg {var} zomg', 'de')
    end

    it 'rejects translations with malformed variable names' do
      string = build_text("rah {var} rah", 'en')
      string.preserve_regex = /\{.*?\}/
      setup_translation(string, 'zomg MUNGED zomg')
      translation = default_translator.translate(string, 'de')

      expect_translation(translation, string, nil, 'de')
    end

    it 'uses translations from database and provider' do
      skip if database_disabled?

      setup_translation('hello.', 'hallo.')
      setup_db_translation('this is a long sentence.', 'short!')

      string = build_text('this is a long sentence. hello.', 'en')
      translator = create_translator(provider: provider) # use db
      translation = translator.translate(string, 'de')

      expect_translation(translation, string, 'short! hallo.', 'de')
    end

    it 'doesn''t translate numbers' do
      string = build_text('1234', 'en')
      translator = create_translator(provider: unused_provider)
      translator.translate(string, 'de')
    end
  end

  def expect_translation(translation, string, result, result_locale)
    tr = translation.get(string, result_locale)
    if result.nil?
      expect(tr).to be_nil
    else
      expect(tr).to be
      expect(tr.result.to_s).to eq(result)
    end
  end

  def default_translator
    create_translator(provider: provider, no_database: true)
  end

  def create_translator(options = {})
    Translatomatic::Translator.new(options)
  end

  def setup_translation(original, results)
    # setup_db_translation(original, results)
    @mapping[original.to_s] = results
  end

  def setup_db_translation(original, results)
    from_locale = create_locale(language: 'en')
    to_locale = create_locale(language: 'de')
    source = create_text(value: original, locale: from_locale)
    results = [results] unless results.is_a?(Array)
    results.each do |result|
      create_text(
        value: result, provider: provider.name,
        locale: to_locale, from_text: source
      )
    end
  end

end
