require_relative 'tubular/bencode'
require_relative 'tubular/torrent'
require_relative 'tubular/tracker'

module Tubular
  def self.download(torrent_file)
    torrent = Torrent.open(torrent_file)
    tracker = Tracker::Tracker.new(torrent)
    resp = tracker.perform
  end
end
