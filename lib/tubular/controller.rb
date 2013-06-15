module Tubular
  # Coordinates piece fetching.
  class Controller
    include Celluloid

    attr_reader :peers

    def initialize
      @peers = []
    end

    def refresh
      PEER_COUNT.times do
        @peers << Tubular.connect_to_peer!
      end
    end
  end
end
