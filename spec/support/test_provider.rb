
class TestProvider < Translatomatic::Provider::Base
  def initialize(result = {})
    @mapping = result
  end

  def perform_translate(strings, _from, _to)
    results = results_from_strings(strings)
    strings.zip(results).collect do |original, translation|
      add_translations(original, translation) unless translation.nil?
    end
  end

  def results_from_strings(strings)
    if @mapping.is_a?(Hash)
      strings.collect { |i| @mapping[i.to_s] }
    else
      strings.collect { @mapping }
    end
  end
end
