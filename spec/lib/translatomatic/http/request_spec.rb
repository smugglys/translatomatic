RSpec.describe Translatomatic::HTTP::Request do
  it 'creates a multipart request' do
    tmx_content = '<xml><rah></rah><rah></rah></xml>'

    request = described_class.new(:post, 'http://www.example.com')
    request.multipart_boundary = '139abc779b36cd8cc2de608c44cd29d7'
    request.body = [
      { key: 'tmx', filename: 'upload.xml',
        content: tmx_content, mime_type: 'application/xml' },
      { key: 'private', value: 0 }
    ]
    expected_body = fixture_read('http_request/multipart_body.txt', true)
    expect(request.http_request.body).to eq(expected_body)
  end
end
