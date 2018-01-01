
class TestTranslator < Translatomatic::Translator::Base
  def initialize(result = {})
    @mapping = result
  end

  def perform_translate(strings, from, to)
    if @mapping.kind_of?(Hash)
      strings.collect { |i| @mapping[i] }
    else
      strings.collect { |i| @mapping }
    end
  end
end
