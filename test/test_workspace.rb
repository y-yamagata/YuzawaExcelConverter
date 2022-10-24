require 'minitest_helper'

describe YEConv::WorkSpace do
  it 'build data' do
    workbook = RubyXL::Parser.parse('./test/test.xlsx')
    workspace = YEConv::WorkSpace.new(workbook)
    source_config = { :sheet => 'テスト' }
    workspace.set(YEConv::Path.new('alice.age'),
                  YEConv::Element::Type::Number,
                  YEConv::Source::Cell.new(source_config.merge({ :cell => 'B2' })))
    workspace.set(YEConv::Path.new('alice.country'),
                  YEConv::Element::Type::String,
                  YEConv::Source::Cell.new(source_config.merge({ :cell => 'C2' })))
    workspace.set(YEConv::Path.new('data[].name'),
                  YEConv::Element::Type::String,
                  YEConv::Source::Table.new(source_config.merge({
                    :direction => 'vertical',
                    :column => 'A',
                    :start_row => '2',
                    :end_if_empty => true
                  })))
    workspace.set(YEConv::Path.new('data[].registered'),
                  YEConv::Element::Type::Boolean,
                  YEConv::Source::Table.new(source_config.merge({
                    :direction => 'vertical',
                    :column => 'D',
                    :start_row => '2',
                    :end_if_empty => true
                  })))
    data = workspace.build
    _(data).must_equal({
      'alice' => {
        'age' => 20,
        'country' => 'アメリカ'
      },
      'data' => [
        {
          'name' => 'Alice',
          'registered' => true
        },
        {
          'name' => 'Bob',
          'registered' => false
        },
        {
          'name' => 'Chris',
          'registered' => true
        }
      ]
    })
  end

  it 'set duplicated value' do
    workbook = RubyXL::Parser.parse('./test/test.xlsx')
    workspace = YEConv::WorkSpace.new(workbook)
    _{
      source_config = { :sheet => 'テスト' }
      workspace.set(YEConv::Path.new('hoge'),
                    YEConv::Element::Type::Number,
                    YEConv::Source::Cell.new(source_config.merge({ :cell => 'B2' })))
      workspace.set(YEConv::Path.new('hoge'),
                    YEConv::Element::Type::String,
                    YEConv::Source::Cell.new(source_config.merge({ :cell => 'C2' })))
    }.must_raise(YEConv::ConverterError)
    _{
      source_config = { :sheet => 'テスト' }
      workspace.set(YEConv::Path.new('piyo[].fuga'),
                    YEConv::Element::Type::Number,
                    YEConv::Source::Cell.new(source_config.merge({ :cell => 'B2' })))
      workspace.set(YEConv::Path.new('piyo[].fuga'),
                    YEConv::Element::Type::String,
                    YEConv::Source::Cell.new(source_config.merge({ :cell => 'C2' })))
    }.must_raise(YEConv::ConverterError)
  end
end
