require 'net/http'
require 'uri'

module Tubular
  module Tracker
    class Tracker
      DEFAULT_PARAMS = {
          info_hash: nil,
          peer_id: nil,
          ip: "0.0.0.0",
          port: 5555,
          uploaded: 0,
          downloaded: 0,
          left: 0,
          event: :started,
          compact: 1
      }

      attr_reader :torrent, :params

      def initialize(environment, params={})
        @environment = environment
        @params = DEFAULT_PARAMS.merge(params)
        @params[:peer_id] = environment.peer_id
        @params[:info_hash] = environment.torrent.info_hash
      end

      def perform
        resp = Net::HTTP.get_response(request_url)

        Response.new(Bencode::parse_from_string(resp.body))
      end

      private

      def request_url
        url = URI(@environment.torrent['announce'])
        url.query = URI.encode_www_form(@params)
        url
      end
    end

    class Response
      attr_reader :body

      def initialize(body)
        @body = body
      end

      def success?
        !body.has_key?('failure reason')
      end

      def peers
        body['peers'].chars.to_a.each_slice(6).map do |peer|
          host = peer[0..3].join.unpack('CCCC').join('.')
          port = peer[4..5].join.unpack('n').first

          { :host => host , :port => port }
        end
      end
    end
  end
end
