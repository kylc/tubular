require 'celluloid/autostart'
require 'celluloid/io'

require_relative 'wire'

module Tubular
  class Peer
    include Wire
    include Celluloid
    # include Celluloid::IO

    def initialize(host, port, environment)
      @host, @port = host, port
      @environment = environment
    end

    def connect
      @socket = TCPSocket.new(@host, @port)

      send_handshake
      recv_handshake

      loop do
        message = recv_message
        p message
      end
    end
  end
end
