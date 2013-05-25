require 'logger'

require_relative 'tubular/bencode'
require_relative 'tubular/torrent'
require_relative 'tubular/tracker'
require_relative 'tubular/peer'

module Tubular
  def self.logger
    @logger ||= Logger.new(STDOUT)
  end

  def self.download(torrent_file)
    # Open the torrent file
    torrent = Torrent.open(torrent_file)

    environment = {
      torrent: torrent,
      peer_id: "aaaaaaaaaaaaaaaaaaaa"
    }

    # Ask the tracker for peers
    tracker = Tracker::Tracker.new(environment)
    resp = tracker.perform

    environment[:tracker] = tracker

    # Connect to the peers
    # TODO: Should select peers in a more intelligent manner
    resp.peers.take(2).each do |peer|
      logger.debug "Connecting to #{peer}"

      conn = Peer.new(peer[:host], peer[:port], environment)
      conn.async.connect
    end

    # Sleep forever!
    sleep
  end
end
