# Translation statistics
class Translatomatic::ConverterStats
  include Translatomatic::Util

  # @return [Array<Translatomatic::Translation>] A list of all translations
  attr_reader :translations

  # @return [Number] The number of translations that came from the database.
  attr_reader :from_db

  # @return [Number] The number of translations that came from the translator.
  attr_reader :from_translator

  private

  def initialize(translations)
    @translations = translations
    @from_db = translations.count { |i| i.from_database }
    @from_translator = translations.count { |i| !i.from_database }
  end

  def to_s
    t("converter.total_translations", total: @translations.length,
      from_db: @from_db, from_translator: @from_translator)
  end
end
