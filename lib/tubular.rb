require 'digest'
require 'logger'
require 'net/http'
require 'stringio'
require 'uri'

require 'celluloid/autostart'
require 'celluloid/io'

require 'tubular/bitfield'
require 'tubular/buffer'
require 'tubular/constant'
require 'tubular/controller'
require 'tubular/bencode'
require 'tubular/torrent'
require 'tubular/tracker'
require 'tubular/protocol'
require 'tubular/peer'
require 'tubular/local'
require 'tubular/version'

module Tubular
  def self.logger
    @logger ||= Logger.new(STDOUT)
  end

  # A 20 character identifier for this client and peer.
  def self.peer_id
    @peer_id ||= "-TB0000-" + (1..12).map { rand(9) }.join
  end

  def self.tracker
    @tracker
  end

  def self.torrent
    @torrent
  end

  def self.local
    @local
  end

  def self.download(torrent_file)
    # Open the torrent file
    @torrent = Torrent.open(torrent_file)

    # Ask the tracker for peers
    @tracker = Tracker.new
    resp = tracker.perform

    @local = LocalFile.new(@torrent.pieces.count)

    @controller = Controller.new
    @controller.refresh

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

  # Connect to a random peer from the tracker's cached response.
  def self.connect_to_peer!
    # Grab a random peer from the last tracker response
    peer = @tracker.cached_response.peers.shuffle.delete_at(0)

    logger.debug "Connecting to #{peer}"

    conn = Peer.new(peer[:host], peer[:port])
    conn.async.connect

    peer
  end
end
