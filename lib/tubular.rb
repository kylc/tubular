require 'logger'

require 'tubular/constant'
require 'tubular/bencode'
require 'tubular/torrent'
require 'tubular/tracker'
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

    # Connect to the peers
    # TODO: Should select peers in a more intelligent manner
    resp.peers.shuffle.take(1).each do |peer|
      logger.debug "Connecting to #{peer}"

      conn = Peer.new(peer[:host], peer[:port])
      conn.async.connect

      @torrent.pieces.each_with_index do |piece, idx|
        conn.request_piece(idx)
      end
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
