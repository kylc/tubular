require_relative 'spec_helper'

describe 'Tubular::Tracker' do
  ANNOUNCE_URL = "http://example.com/announce"
  ANNOUNCE_MATCH = /http:\/\/example.com\/announce\/*/

  subject do
    torrent = Minitest::Mock.new
    torrent.expect(:[], ANNOUNCE_URL, ['announce'])
    torrent.expect(:info_hash, 'a' * 20)

    Tubular::Tracker::Tracker.new(torrent)
  end

  it "must be able to parse peers" do
    body = "d5:peers12:\xB9\x15\xD8\x87\xCC7^\xB5\xBA,\x9Bbe"
    stub_request(:get, ANNOUNCE_MATCH)
      .to_return(:status => 200, :body => body)

    resp = subject.perform
    resp.success?.must_equal true
    resp.peers.must_equal [{ :host => "185.21.216.135", :port => 52279 },                            { :host => "94.181.186.44", :port => 39778 }]
  end
end
