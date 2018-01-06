# Converts files from one format to another
class Translatomatic::Converter

  def initialize(options = {})
    @options = options
  end

  # Convert a resource file from one format to another.
  # @param source [String] Path to source file. File must exist
  # @param target [String] Path to target file. File will be created
  #   or overwritten if it already exists.
  # @return [Translatomatic::ResourceFile] The converted file.
  def convert(source, target)
    source_path = Pathname.new(source.to_s)
    target_path = Pathname.new(target.to_s)
    raise t("file.not_found", file: source.to_s) unless source_path.file?
    raise t("file.directory", file: target.to_s) if target_path.directory?

    source_file = load_file(source_path)
    target_file = load_file(target_path)

    # copy properties from source file to target
    target_file.properties = source_file.properties
    target_file.save(target_path, @options)
    target_file
  end

  private

  def load_file(path)
    file = Translatomatic::ResourceFile.load(path)
    raise t("file.unsupported", file: path) unless file
    file
  end

end
