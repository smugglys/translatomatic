# resource bundle
# resource bundle consists of a source file to translate
# and one or more output files.
class Translatomatic::ResourceBundle

  def initialize(source, targets)
    @source = ResourceFile.new(source)
    @targets = targets.collect { |i| ResourceFile.new(i) }
  end

  def to_s
    "source: #{source}, targets: #{targets}"
  end

  def self.from_property_file(path)
    basename = File.basename(path, ".properties")
    dir = File.dirname(path)
    targets = Dir.glob(File.join(dir, "basename_*.properties"))
    new(path, targets)
  end

  def self.from_xcode_project(path)

  end
end
