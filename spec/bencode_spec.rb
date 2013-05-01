require 'minitest/autorun'
require 'stringio'

require_relative '../lib/tubular/bencode'

describe 'Tubular::Bencode' do
  before do
    @parser = Tubular::Bencode::Parser.new
  end

  it "can parse integers" do
    parsed = @parser.parse(StringIO.new("i42e"))

    parsed.must_equal 42
  end

  it "can parse strings" do
    parsed = @parser.parse(StringIO.new("11:hello world"))

    parsed.must_equal "hello world"
  end

  it "can parse lists" do
    parsed = @parser.parse(StringIO.new("li5ei10e2:hie"))

    parsed.must_equal [5, 10, "hi"]
  end

  it "can parse dictionaries" do
    parsed = @parser.parse(StringIO.new("d3:cow3:moo4:spam4:eggse"))

    parsed.must_equal({ "cow" => "moo", "spam" => "eggs" })
  end
end
