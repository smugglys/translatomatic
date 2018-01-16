RSpec.describe Translatomatic::Converter do
  def self.sane_conversion?(source, target)
    source != target && source.key_value? && target.key_value?
  end

  Translatomatic::ResourceFile.types.each do |source_type|
    Translatomatic::ResourceFile.types.each do |target_type|
      next unless sane_conversion?(source_type, target_type)
      format1 = source_type.name.demodulize
      format2 = target_type.name.demodulize
      it "converts #{format1} files to #{format2} files" do
        converter = Translatomatic::Converter.new(no_created_by: true)
        source = test_file(source_type)
        target = create_tempfile("output.#{target_type.extensions[0]}")
        target.delete if target.exist?
        converter.convert(source, target)

        # test that the written properties match the expected output
        expected_output = test_resource_file(target_type)
        puts 'written output:'
        puts target.read
        output = Translatomatic::ResourceFile.load(target)
        expect(output.properties).to eq(expected_output.properties)
      end
    end
  end

  private

  def test_resource_file(type)
    Translatomatic::ResourceFile.load(test_file(type))
  end

  # return converter test file for the given resource file type
  def test_file(type)
    fixture_path("converter/test.#{type.extensions[0]}")
  end
end
