require 'json'
require 'minitest_helper'

describe YEConv::Converter do
  before do
    if File.exist?('./test/output/test_output.json')
      File.delete('./test/output/test_output.json')
    end
  end

  it 'converts with file' do
    result_set = YEConv::convert_with_file('./test/test.toml', output_dir: './test/output')
    _(result_set.success?(:test)).must_equal(true)
    output_content = File.read('./test/output/test_output.json', :encoding => 'utf-8')
    _(JSON.parse(output_content)).must_equal({
      'origin' => './test/test.xlsx',
      'users' => [
        {
          'name' => 'Alice',
          'age' => 20,
          'country' => 'アメリカ',
          'registered' => true,
          'living_in_america' => true
        },
        {
          'name' => 'Bob',
          'age' => 30,
          'country' => 'イギリス',
          'registered' => false,
          'living_in_america' => false
        },
        {
          'name' => 'Chris',
          'age' => 40,
          'country' => '日本',
          'registered' => true,
          'living_in_america' => false
        }
      ]
    })
  end

  # it 'converts with config string' do
  # end

  # it 'converts with filtering keys' do
  # end
end
