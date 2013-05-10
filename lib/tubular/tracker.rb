require 'net/http'
require 'uri'

module Tubular
  class Tracker
    attr_reader :torrent

    def initialize(torrent)
      @torrent = torrent
    end

    def request
      params = {
        info_hash: @torrent.info_hash,
        peer_id: "aaaaaaaaaaaaaaaaaaaa",
        ip: "0.0.0.0",
        port: 5555,
        uploaded: 0,
        downloaded: 0,
        left: 0,
        event: :started,
        compact: 1
      }

      uri = URI(@torrent['announce'])
      uri.query = URI.encode_www_form(params)

      resp = Net::HTTP.get_response(uri)

      Bencode::parse_from_string(resp.body)
    end

    def decode_peers(binary)
      peers = []

      binary.chars.to_a.each_slice(6) do |peer|
        ip = peer[0..3].join.unpack('CCCC').join('.')
        port = peer[4..5].join.unpack('n').first

        peers << [ip, port].join(':')
      end

      peers
    end
  end
end
