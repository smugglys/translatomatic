RSpec.describe Translatomatic::HTTPRequest do
  it 'creates a multipart request' do
    request = described_class.new('http://www.example.com')
    content = '<xml><rah></rah><rah></rah></xml>'
    request.multipart_boundary = '139abc779b36cd8cc2de608c44cd29d7'
    body = request.send(:multipartify, [
                          request.file(key: 'tmx', filename: 'upload.xml', content: content, mime_type: 'application/xml'),
                          request.param(key: 'private', value: 0)
                        ])
    expected_body = fixture_read('http_request/multipart_body.txt', true)
    expect(body).to eq(expected_body)
  end
end
