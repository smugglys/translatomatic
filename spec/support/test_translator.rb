
class TestTranslator < Translatomatic::Translator::Base
  def initialize(result = {})
    @mapping = result
  end

  def perform_translate(strings, _from, _to)
    if @mapping.is_a?(Hash)
      strings.collect { |i| @mapping[i] }
    else
      strings.collect { |_i| @mapping }
    end
  end
end
