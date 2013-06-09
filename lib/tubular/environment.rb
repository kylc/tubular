module Tubular
  class Environment
    # The current tracker.
    attr_accessor :tracker

    # The torrent we are currently operating upon.
    attr_accessor :torrent

    # Our peer ID.
    attr_accessor :peer_id

    # The local file.
    attr_accessor :local
  end
end
