require 'minitest_helper'

describe YEConv::Path do
  it 'is converted to string' do
    path = YEConv::Path.new('hoge.piyo[].fuga')
    _(path.to_s).must_equal('hoge.piyo[].fuga')
  end

  it 'gives car' do
    path = YEConv::Path.new('hoge.piyo[].fuga')
    _(path.car.to_s).must_equal('hoge')
  end

  it 'gives cdr' do
    path = YEConv::Path.new('hoge.piyo[].fuga')
    _(path.cdr.to_s).must_equal('piyo[].fuga')
  end

  it 'is only edge?' do
    path = YEConv::Path.new('hoge.fuga')
    _(path.edge?).must_equal(false)
    path = path.cdr
    _(path.edge?).must_equal(true)
  end

  it 'is empty?' do
    path = YEConv::Path.new('hoge')
    _(path.empty?).must_equal(false)
    path = path.cdr
    _(path.empty?).must_equal(true)
  end
end
