require 'minitest_helper'

describe YEConv::Loader::Loaders do
  it 'gives file loader' do
    loader = YEConv::Loader::Loaders::get_loader('file:///path/to/file')
    _(loader.is_a?(YEConv::Loader::FileLoader)).must_equal(true)
    loader = YEConv::Loader::Loaders::get_loader('/path/fo/file')
    _(loader.is_a?(YEConv::Loader::FileLoader)).must_equal(true)
  end

  it 'gives http loader' do
    loader = YEConv::Loader::Loaders::get_loader('http://example.com')
    _(loader.is_a?(YEConv::Loader::HttpLoader)).must_equal(true)
    loader = YEConv::Loader::Loaders::get_loader('https://example.com')
    _(loader.is_a?(YEConv::Loader::HttpLoader)).must_equal(true)
  end
end
