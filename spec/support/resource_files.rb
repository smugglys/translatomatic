require 'fileutils'

RSpec.shared_examples "a resource file" do |config|

  TEST_LOCALE_LIST ||= [
    "de",
    "de-DE",
    "en-US",
    "zh-Hant"
  ]

  it "loads a file" do
    file = load_test_file
    expect(file).to be
    expected_properties = config[:load_properties] || {
      "key1" => "value 1",
      "key2" => "value 2",
    }
    expect(file.properties).to eq(expected_properties)
  end

  it "saves a file" do
    file = load_test_file

    ext = described_class.extensions.first
    save_path = create_tempfile("test.#{ext}")
    file.properties = config[:save_properties] || {
      "key1" => "saved value 1",
      "key2" => "saved value 2",
    }
    file.save(save_path)
    expected_result = fixture_path("test_save.#{ext}")
    expect(save_path.read).to eql(File.read(expected_result))
  end

  config[:locale_path_conversions].each do |conversion|
    TEST_LOCALE_LIST.each do |source_locale|
      TEST_LOCALE_LIST.each do |target_locale|
        described_class.extensions.each do |ext|
          source = conversion.source(ext, source_locale)
          target = conversion.target(ext, target_locale)
          it "converts '#{source}' to '#{target}'" do
            file = described_class.new(source)
            expect(file.locale_path(target_locale).to_s).to eq(target)
          end
        end
      end
    end
  end

  config[:locale_path_conversions].each do |conversion|
    TEST_LOCALE_LIST.each do |locale|
      described_class.extensions.each do |ext|
        target = conversion.target(ext, locale)
        it "detects locale '#{locale}' from '#{target}'" do
          file = described_class.new(target)
          expect(file.locale.to_s).to eq(locale)
        end
      end
    end
  end

  private

  def load_test_file
    ext = described_class.extensions.first
    path = fixture_path("test.#{ext}")
    described_class.new(path)
  end
end  # end shared examples

class PathConversion

  def initialize(from, to)
    @source = from
    @target = to
  end

  def source(ext, locale)
    subst(@source, ext, locale)
  end

  def target(ext, locale)
    subst(@target, ext, locale)
  end

  private

  def subst(string, ext, locale)
    string.sub("$EXT", ext).sub("$LOC", locale)
  end
end
