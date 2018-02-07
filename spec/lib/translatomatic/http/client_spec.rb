RSpec.describe Translatomatic::HTTP::Client do
  it 'creates a new client' do
    client = described_class.new
    expect(client).to be
  end

  it 'sends a get request' do
    url = 'http://www.example.com'
    stub_get(url)

    client = described_class.new
    response = client.get(url)
    expect(response).to be_kind_of(Net::HTTPSuccess)
  end

  it 'follows redirects' do
    url1 = 'http://www.example.com'
    url2 = 'http://www.example.com/redirected_to'
    expected_response = 'expected response'

    stub_redirect(url1, url2)
    stub_get(url2, expected_response)

    client = described_class.new
    response = client.get(url1)
    expect(response.body).to eq(expected_response)
  end

  it 'retries up to 3 times on timeout' do
    url = 'http://www.example.com'
    request = stub_get(url, 'request timeout', 408) # timeout

    client = described_class.new(retry_delay: 0)
    expect { client.get(url) }.to raise_error(/request timeout/)
    expect(request).to have_been_made.times(3)
  end

  it 'does not retry non-retriable requests' do
    url = 'http://www.example.com'
    request = stub_get(url, 'request forbidden', 403) # forbidden

    client = described_class.new(retry_delay: 0)
    expect { client.get(url) }.to raise_error(/request forbidden/)
    expect(request).to have_been_made.once
  end

  private

  def stub_get(url, response_body = '', status = 200)
    stub_request(:get, url)
      .with(headers: test_http_headers)
      .to_return(status: status, body: response_body, headers: {})
  end

  def stub_redirect(from, to, response_body = '')
    stub_request(:get, from)
      .with(headers: test_http_headers)
      .to_return(status: 302, body: response_body, headers: {
                   'Location' => to
                 })
  end
end
