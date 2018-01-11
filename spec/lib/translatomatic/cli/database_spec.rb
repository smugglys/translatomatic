RSpec.describe Translatomatic::CLI::Database do
  include DatabaseHelpers

  before(:each) do
    skip if database_disabled?
    @cli = Translatomatic::CLI::Database.new
    @cli.options = { database_env: "test" }
    @locale_en = create_locale(language: :en)
    @locale_de = create_locale(language: :de)
  end

  context :search do
    it "searches for text in the database" do
      skip if database_disabled?
      text = create_text(locale: @locale_en, value: "rah rah rah")
      @cli.search(text.value)
    end

    it "searches for text in the database with specified locale" do
      skip if database_disabled?
      text = create_text(locale: @locale_en, value: "foo")
      create_text(locale: @locale_de, from_text: text, value: "rah")

      @cli.search(text.value, "en")
    end
  end

  private

  def add_cli_options(options = {})
    @cli.options = @cli.options.merge(options)
  end

end
