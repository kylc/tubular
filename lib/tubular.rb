require 'logger'

require 'tubular/constant'
require 'tubular/bencode'
require 'tubular/torrent'
require 'tubular/tracker'
require 'tubular/peer'
require 'tubular/version'

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

    # TODO: Orchestrate piece downloading.
    # Strategy:
    #
    # Order pieces by scarcity
    # 
    # Shift pieces off the queue
    #
    # Find a suitable peer
    #
    # Request the piece (of multiple blocks)

    # Sleep forever!
    sleep
  end
end
