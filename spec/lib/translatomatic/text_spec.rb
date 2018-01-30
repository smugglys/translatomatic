RSpec.describe Translatomatic::Text do
  STRING_DATA = [
    # type detection tests
    ['en', :phrase, 'The bewildered tourist'],
    ['en', :sentence, 'The bewildered tourist was lost.'],
    ['en', :paragraph, 'The bewildered tourist was lost. He should have turned left at Albuquerque.',
     ['The bewildered tourist was lost.',
      'He should have turned left at Albuquerque.']],

    # non-sentences containing '.'
    ['en', :phrase, 'display the *store.description* property'],
    ['en', :phrase, 'http://www.google.com/'],

    # text containing newlines
    ['en', :paragraph, "FEATURES:\n- feature 1\n- feature 2",
     ['FEATURES:', '- feature 1', '- feature 2']],

    # english sentences
    ['en', :paragraph, 'sentence one. sentence two.',
     ['sentence one.', 'sentence two.']],
    # sentence with full stop missing from last sentence
    ['en', :paragraph, 'sentence one. sentence two',
     ['sentence one.', 'sentence two']],
    # sentence starting with full stop
    # this can happen with markdown to text conversion, e.g.
    #  "<b>sentence one</b>. sentence two" converts to two separate text nodes.
    ['en', :paragraph, '. sentence two.',
     ['.', 'sentence two.']],
    # sentence starting with full stop and missing end full stop
    ['en', :paragraph, '. sentence two',
     ['.', 'sentence two']],
    # sentence with leading and trailling spaces
    ['en', :paragraph, '   sentence one.   sentence two.  ',
     ['sentence one.', 'sentence two.']],
    # sentence starting on a newline with missing end full stop
    ['en', :paragraph, "  sentence one.\nsentence two",
     ['sentence one.', 'sentence two']],
    # sentence with newline mid-sentence
    ['en', :paragraph, "  sentence one. sentence\ntwo",
     ['sentence one.', 'sentence', 'two']]
  ].freeze

  context :new do
    it 'creates a string using a string tag' do
      string = Translatomatic::Text.new('test', 'en')
      expect(string).to be
      expect(string.locale.language).to eq('en')
    end

    it 'creates a string using a locale object' do
      locale = build_locale('en-US')
      string = Translatomatic::Text.new('test', locale)
      expect(string).to be
      expect(string.locale.language).to eq('en')
    end
  end

  context :substring do
    it 'creates substrings' do
      string = build_text('sentence one. sentence two.', 'en')
      expect(string.substring?).to be_falsey
      sentences = string.sentences
      expect(sentences[0].substring?).to be_truthy
      expect(sentences[0].parent).to eq(string)
    end

    it 'sets the correct offset' do
      string = build_text('word1 {var1} word3', 'en')
      variables = string.substrings(/\{\w+\}/)
      expect(variables.length).to eq(1)
      expect(variables[0].offset).to eq(6)
    end
  end

  context :type do
    STRING_DATA.each do |tag, type, input, _output|
      it "recognises '#{input}' as type '#{type}'" do
        expect(build_text(input, tag).type).to eq(type)
      end
    end
  end

  context :sentences do
    it 'returns itself if there is only one sentence' do
      string = build_text('test sentence', 'en')
      expect(string.sentences[0]).to equal(string)
    end

    it 'sets correct offsets for repeated sentences' do
      string = build_text('sentence. sentence.', 'en')
      sentences = string.sentences
      expect(sentences[0].offset).to eq(0)
      expect(sentences[1].offset).to eq(10)
    end

    STRING_DATA.each do |tag, _type, input, output|
      output ||= [input]
      s = output.length == 1 ? '' : 's'
      it "splits '#{input}' into #{output.length} sentence#{s}" do
        string = build_text(input, tag)
        output = output.collect { |i| build_text(i, tag) }
        expect(string.sentences).to eq(output)
      end
    end
  end
end
