require 'minitest_helper'
require 'rubyXL'

describe YEConv::Source::Cell do
  it 'gets values with sheet name' do
    workbook = RubyXL::Parser.parse('./test/test.xlsx')
    ref = YEConv::Source::Cell.new({ :sheet => 'テスト', :cell => 'B2' })
    values = ref.values(workbook)
    _(values[0]).must_equal(20)
  end

  it 'gets values with sheet index' do
    workbook = RubyXL::Parser.parse('./test/test.xlsx')
    ref = YEConv::Source::Cell.new({ :sheet => 0, :cell => 'A2' })
    values = ref.values(workbook)
    _(values[0]).must_equal('Alice')
  end
end

describe YEConv::Source::Range do
  it 'get values' do
    workbook = RubyXL::Parser.parse('./test/test.xlsx')
    ref = YEConv::Source::Range.new({
      :sheet => 0,
      :from => 'C2',
      :to => 'D4',
      :direction => 'vertical'
    })
    values = ref.values(workbook)
    _(values).must_equal(['アメリカ', 'イギリス', '日本', 1, 0, 1])
  end
end

describe YEConv::Source::Table do
  it 'get vertical values during exists' do
    workbook = RubyXL::Parser.parse('./test/test.xlsx')
    ref = YEConv::Source::Table.new({
      :sheet => 0,
      :direction => 'vertical',
      :column => 'A',
      :start_row => '2',
      :end_if_empty => true
    })
    values = ref.values(workbook)
    _(values).must_equal(['Alice', 'Bob', 'Chris'])
  end

  it 'get horizontal values from start and end' do
    workbook = RubyXL::Parser.parse('./test/test.xlsx')
    ref = YEConv::Source::Table.new({
      :sheet => 0,
      :direction => 'vertical',
      :column => 'A',
      :start_row => '2',
      :end_row => '4'
    })
    values = ref.values(workbook)
    _(values).must_equal(['Alice', 'Bob', 'Chris'])
  end
end
