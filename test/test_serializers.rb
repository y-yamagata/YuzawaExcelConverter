require 'minitest_helper'

describe YEConv::Serializer::JsonSerializer do
  it 'serializes to json' do
    serializer = YEConv::Serializer::Serializers.get_serializer('json')
    r = serializer.serialize({ :hoge => [1, 2, 3] })
    _(r).must_equal('{"hoge":[1,2,3]}')
    r = serializer.serialize({ :hoge => [1, 2, 3] }, :pretty => true)
    _(r).must_equal("{\n  \"hoge\": [\n    1,\n    2,\n    3\n  ]\n}")
  end
end
