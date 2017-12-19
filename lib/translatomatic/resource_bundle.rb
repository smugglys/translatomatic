# resource bundle
# resource bundle consists of a source file to translate
# and one or more output files.
class Translatomatic::ResourceBundle

  def initialize(source, targets)
    @source = Translatomatic::ResourceFile.new(source)
    @targets = targets.collect { |i| Translatomatic::ResourceFile.new(i) }
  end

  def to_s
    "source: #{source}, targets: #{targets}"
  end

end
