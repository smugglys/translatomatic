RSpec.describe Translatomatic::ResourceFile::CSV do
  include_examples 'a resource file',
                   load_properties: {
                     'key1,1' => 'row 1',
                     'key1,2' => 'value 1',
                     'key2,1' => 'row 2',
                     'key2,2' => 'value 2'
                   },
                   save_properties: {
                     'key1,2' => 'saved value 1',
                     'key2,2' => 'saved value 2'
                   }

  it 'handles csv files with headers' do
    options = {
      csv_headers: true, csv_key: 'key header', csv_value: 'value header'
    }
    file = load_test_file('test_headers.csv', options)
    expect(file).to be
    # properties should not include headers
    # 2 rows * 3 columns = 6 properties
    expect(file.properties.length).to eq(6)
  end

  it 'preserves headers on save' do
    options = {
      csv_headers: true,
    }
    file = load_test_file('test_headers.csv', options)
    file.properties = {
      'key1,2' => 'saved value 1',
      'key2,2' => 'saved value 2'
    }
    test_save(file, fixture_read('test_headers_save.csv'))
  end

  # test selecting columns with the csv_columns option
  it 'loads only selected columns' do
    options = {
      csv_headers: true,
      csv_columns: ['header 1', 'header 2']
    }
    file = load_test_file('test_headers.csv', options)
    # 2 columns * 2 rows
    expect(file.properties.length).to eq(4)
  end

  # only load the second column into @properties, but writing the file
  # should retain all original data.
  it 'preserves all data when columns are selected' do
    options = {
      csv_headers: true,
      csv_columns: ['header 2']
    }
    file = load_test_file('test_headers.csv', options)
    file.properties = {
      'key1,2' => 'saved value 1',
      'key2,2' => 'saved value 2'
    }
    test_save(file, fixture_read('test_headers_save.csv'))
  end
end
