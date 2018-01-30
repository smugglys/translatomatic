
class TestProvider < Translatomatic::Provider::Base
  def initialize(result = {})
    @mapping = result
  end

  def perform_translate(strings, _from, to)
    results = results_from_strings(strings, to)
    strings.zip(results).collect do |original, translation|
      add_translations(original, translation) unless translation.nil?
    end
  end

  def results_from_strings(strings, to)
    if @mapping.is_a?(Hash)
      langmap = @mapping.include?(to.to_s) ? @mapping[to.to_s] : @mapping
      strings.collect { |i| langmap[i.to_s] }
    else
      strings.collect { @mapping }
    end
  end
end
