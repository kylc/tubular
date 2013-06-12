module Tubular
  class Environment
    # The current tracker.
    attr_accessor :tracker

    # The torrent we are currently operating upon.
    attr_accessor :torrent

    # The local file.
    attr_accessor :local
  end
end
