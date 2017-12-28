RSpec.describe Translatomatic::Translator::Frengly do
  it "requires an email" do
    expect { described_class.new }.to raise_error(/email.*required/)
  end

  it "requires a password" do
    expect {
      described_class.new(frengly_email: "rah")
    }.to raise_error(/password required/)
  end

  it "returns a language list" do
    t = described_class.new(frengly_email: "dummy", frengly_password: "dummy")
    expect(t.languages).to_not be_empty
  end

  it "translates strings" do
    # TODO: work out what the response looks like
    api_endpoint = "http://frengly.com/frengly/data/translateREST"
    expected_response = { text: "Bier" }
    stub_request(:post, api_endpoint).
      with(body: "{\"src\":\"en\",\"dest\":\"de\",\"text\":\"Beer\",\"email\":\"dummy\",\"password\":\"dummy\",\"premiumkey\":null}",
           headers: {
             'Accept'=>'*/*',
             'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
             'Content-Type'=>'application/json',
             'Host'=>'frengly.com', 'User-Agent'=>'Ruby'}).
      to_return(status: 200, body: expected_response.to_json, headers: {})

    t = described_class.new(frengly_email: "dummy", frengly_password: "dummy")
    results = t.translate("Beer", "en", "de")
    expect(results).to eq(["Bier"])
    expect(WebMock).to have_requested(:post, api_endpoint)
  end
end
