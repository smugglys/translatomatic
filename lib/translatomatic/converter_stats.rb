# Translation statistics
class Translatomatic::ConverterStats

  # @return [Number] The total number of strings translated.
  attr_reader :translations

  # @return [Number] The number of translations that came from the database.
  attr_reader :from_db

  # @return [Number] The number of translations that came from the translator.
  attr_reader :from_translator

  def initialize(from_db, from_translator)
    @translations = from_db + from_translator
    @from_db = from_db
    @from_translator = from_translator
  end

  def +(other)
    self.class.new(@from_db + other.from_db, @from_translator + other.from_translator)
  end

  def to_s
    "Total translations: #{@translations} " +
      "(#{@from_db} from database, #{@from_translator} from translator)"
  end
end
