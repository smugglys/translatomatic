# Translation statistics
class Translatomatic::ConverterStats
  include Translatomatic::Util

  # @return [Number] The total number of strings translated.
  attr_reader :translations

  # @return [Number] The number of translations that came from the database.
  attr_reader :from_db

  # @return [Number] The number of translations that came from the translator.
  attr_reader :from_translator

  private

  def initialize(from_db, from_translator)
    @translations = from_db + from_translator
    @from_db = from_db
    @from_translator = from_translator
  end

  def to_s
    t("converter.total_translations", total: @translations,
      from_db: @from_db, from_translator: @from_translator)
  end
end
