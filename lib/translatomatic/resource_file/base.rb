class Translatomatic::ResourceFile::Base
  attr_reader :data  # hash of key -> value
  attr_reader :path
  attr_reader :locale
  attr_reader :contents
  attr_reader :format
  attr_reader :properties

  def initialize(path)
    @path = path
    @language, @region = parse_language_region(path)
  end

  def get(name)
    @properties[name]
  end

  def set(key, value)
    @properties[key] = value
  end

  def valid?
    false
  end

  def save
    raise "save must be implemented by subclass"
  end

  private

  # detect language/region from filename
  def parse_language_region(path)
    basename = File.basename(path, ".properties")
    m = /strings_(\w+)(:?_(\w+))?/.match(basename)
    m ? m.captures : []
  end

end
