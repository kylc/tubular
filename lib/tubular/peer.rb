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

        Tubular.logger.debug "Message: #{message}"

        case message.type
        when :bitfield
          @piece_map = message.payload[:bitfield]
          p @piece_map.length
        when :have
          @piece_map[message.payload[:piece_index]] = true
        end
      end
    end
  end
end
