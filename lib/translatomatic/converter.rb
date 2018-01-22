module Translatomatic
  # Converts files from one format to another
  class Converter
    def initialize(options = {})
      @options = options
    end

    # Convert a resource file from one format to another.
    # @param source [String] Path to source file. File must exist
    # @param target [String] Path to target file. File will be created
    #   or overwritten if it already exists.
    # @return [Translatomatic::ResourceFile] The converted file.
    def convert(source, target)
      source_file = load_file(source)
      target_file = load_file(target)
      raise t('file.not_found', file: source) unless source_file.path.file?

      if source_file.type == target_file.type
        # if same file type, modify source.
        # this retains internal structure
        target_file = source_file
      else
        # different file type, copy properties from source file to target
        target_file.properties = source_file.properties
      end

      target_file.save(target, @options)
      target_file
    end

    private

    include Translatomatic::Util

    def load_file(path)
      path = Pathname.new(path.to_s)
      raise t('file.directory', file: path) if path.directory?

      file = if path.exist?
               Translatomatic::ResourceFile.load(path)
             else
               Translatomatic::ResourceFile.create(path)
             end
      raise t('file.unsupported', file: path) unless file
      file
    end
  end
end
