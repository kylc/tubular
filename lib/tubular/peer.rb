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

      @choked, @interested = true, false
      @am_choking, @am_interested = true, false
    end

    def connect
      @socket = TCPSocket.new(@host, @port)

      send_handshake
      recv_handshake

      loop do
        message = recv_message

        Tubular.logger.debug "Message: #{message}"

        case message.type
        when :choke
          @choked = true
        when :unchoke
          @choked = false
        when :interested
          @interested = true
        when :notinterested
          @interested = false
        when :have
          @piece_map[message.payload[:piece_index]] = true
        end
      end
    end

    # Whether or not we are currently interested in this peer.
    def am_interested
      @am_interested
    end

    def am_interested=(interest)
      @am_interested = interest
      message_type = interest ? :interested : :notinterested
      message = Message.new(message_type)
      send_message(message)
    end

    # Whether or not we are currently choking this peer.
    def am_choking
      @am_choking
    end

    def am_choking=(choking)
      @am_choking = choking
      message_type = choking ? :choke : :unchoke
      message = Message.new(message_type)
      send_message(message)
    end
  end
end
