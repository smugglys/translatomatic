RSpec.describe Translatomatic::CLI::Database do

  before(:each) do
    @cli = Translatomatic::CLI::Database.new
    @cli.options = { database_env: "test" }
    @locale_en = Translatomatic::Model::Locale.find_or_create_by!(language: :en)
    @locale_de = Translatomatic::Model::Locale.find_or_create_by!(language: :de)
  end

  context :search do
    it "searches for text in the database" do
      text = FactoryBot.create(:text_model, locale: @locale_en)
      @cli.search(text.value)
    end

    it "searches for text in the database with specified locale" do
      text = FactoryBot.create(:text_model, locale: @locale_en)
      FactoryBot.create(:text_model, locale: @locale_de, from_text: text)

      @cli.search(text.value, "en")
    end
  end

  private

  def add_cli_options(options = {})
    @cli.options = @cli.options.merge(options)
  end

end
