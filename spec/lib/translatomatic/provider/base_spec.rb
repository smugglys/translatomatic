RSpec.describe Translatomatic::Provider::Base do
  class DummyProvider < described_class
    attr_accessor :use_perform_fetch_translations

    def initialize(url)
      @url = url
      http_client(retry_delay: 0)  # initialize client with no retry delay
    end

    def perform_translate(strings, from, to)
      if use_perform_fetch_translations
        perform_fetch_translations(@url, strings, from, to)
      else
        [http_client.get(@url).body]
      end
    end

    def fetch_translations(_strings, _from, _to)
      http_client.get(@url).body
    end
  end

  context :languages do
    it 'returns an empty language list by default' do
      t = DummyProvider.new(nil)
      expect(t.languages).to be_empty
    end
  end

  context :name do
    it 'returns the provider name' do
      t = DummyProvider.new(nil)
      expect(t.name).to eq(DummyProvider.to_s)
    end
  end

  context :perform_fetch_translations do
    it 'succeeds after 2 retriable errors' do
      url = 'http://www.example.com'
      t = DummyProvider.new(url)
      stub_request_failures(url, 2)
      t.use_perform_fetch_translations = true
      expect do
        t.translate('String', 'en', 'de')
      end.to_not raise_error
    end

    it 'stops after failing 3 times' do
      url = 'http://www.example.com'
      t = DummyProvider.new(url)
      stub_request_failures(url, 3)
      t.use_perform_fetch_translations = true
      expect do
        t.translate('String', 'en', 'de')
      end.to raise_error(Translatomatic::HTTP::Exception)
    end
  end

  private

  def stub_request_failures(url, count)
    response_body = 'Result'

    @failures ||= {} # url -> fail count
    stub_request(:get, url)
      .with(headers: test_http_headers)
      .to_return(lambda { |request|
        @failures[request.uri] ||= 0
        fail_count = @failures[request.uri] += 1
        if fail_count <= count
          { status: 500, body: '', headers: {} }
        else
          { status: 200, body: response_body, headers: {} }
        end
      })
  end
end
