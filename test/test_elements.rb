require 'minitest_helper'

describe YEConv::Element::NumberElement do
  it 'sets value' do
    element = YEConv::Element::NumberElement.new(:key, nil)
    element.set('10')
    _(element.value).must_equal(10)
  end

  it 'sets value with formatter' do
    element = YEConv::Element::NumberElement.new(:key, nil,
                                                 formatter: lambda { |v| v * 2 })
    element.set(10)
    _(element.value).must_equal(20)
  end
end

describe YEConv::Element::StringElement do
  it 'set value' do
    element = YEConv::Element::StringElement.new(:key, nil)
    element.set('hoge')
    _(element.value).must_equal('hoge')
  end
end

describe YEConv::Element::BooleanElement do
  it 'set value' do
    element = YEConv::Element::BooleanElement.new(:key, nil)
    element.set('true')
    _(element.value).must_equal(true)
  end
end

describe YEConv::Element::ListElement do
  it 'imitate array' do
    element = YEConv::Element::ListElement.new(:key, nil)
    element[0] = 'hoge'
    element[1] = 'piyo'
    _(element[0]).must_equal('hoge')
    _(element[1]).must_equal('piyo')
    element.each.with_index(0) do |v, index|
      if index == 0
        _(v).must_equal('hoge')
      elsif index == 1
        _(v).must_equal('piyo')
      end
    end
  end
end

describe YEConv::Element::ObjectElement do
  it 'imitate object' do
    element = YEConv::Element::ObjectElement.new(:key, nil)
    element[:hoge] = 'hoge'
    element[:piyo] = 'piyo'
    _(element[:hoge]).must_equal('hoge')
    _(element[:piyo]).must_equal('piyo')
  end
end
