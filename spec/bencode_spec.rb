require_relative 'spec_helper'

describe 'Tubular::Bencode' do
  it "can parse integers" do
    parsed = Tubular::Bencode.parse_from_string("i42e")

    parsed.must_equal 42
  end

  it "can parse strings" do
    parsed = Tubular::Bencode.parse_from_string("11:hello world")

    parsed.must_equal "hello world"
  end

  it "can parse lists" do
    parsed = Tubular::Bencode.parse_from_string("li5ei10e2:hie")

    parsed.must_equal [5, 10, "hi"]
  end

  it "can parse dictionaries" do
    parsed = Tubular::Bencode.parse_from_string("d3:cow3:moo4:spam4:eggse")

    parsed.must_equal({ "cow" => "moo", "spam" => "eggs" })
  end
end
