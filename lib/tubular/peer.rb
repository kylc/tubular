require 'celluloid/autostart'
require 'celluloid/io'

require_relative 'wire'

module Tubular
  class Peer
    include Celluloid

    attr_reader :choked, :interested

    attr_reader :am_choking, :am_interested

    def initialize(host, port, environment)
      @host, @port = host, port
      @environment = environment

      @choked, @interested = true, false
      @am_choking, @am_interested = true, false

      @connection = Connection.new(Actor.current, @host, @port, @environment)

      @piece_map = Bitfield.empty(@environment[:torrent].pieces.length)
    end

    def connect
      @connection.async.connect

      every(30) do
        if (Time.now - @last_message_time) >= 30
          puts "SENDING KEEPALIVE"
          @connection.send_message Wire::Message.new(:keep_alive)
        end
      end
    end

    def handle(message)
      Tubular.logger.debug "Message: #{message}"

      @last_message_time = Time.now

      case message.type
      when :keep_alive
        @connection.send_message Wire::Message.new(:keep_alive)
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
      when :bitfield
        # TODO: Technically this is only allowed immediately following the
        # handshake...  after any other messages are sent a bitfield can no
        # longer be sent.
        @piece_map = message.payload[:bitfield]
      when :request
      when :piece
      when :cancel
      when :port
      end
    end

    def am_interested=(interest)
      @am_interested = interest
      message_type = interest ? :interested : :notinterested
      message = Wire::Message.new(message_type)
      @connection.send_message(message)
    end

    def am_choking=(choking)
      @am_choking = choking
      message_type = choking ? :choke : :unchoke
      message = Wire::Message.new(message_type)
      @connection.send_message(message)
    end
  end

  class Connection
    include Celluloid
    include Wire

    def initialize(sink, host, port, environment)
      @sink = sink
      @host, @port = host, port
      @environment = environment
    end

    def connect
      @socket = TCPSocket.new(@host, @port)

      send_handshake
      recv_handshake

      run
    end

    def run
      loop do
        message = recv_message
        @sink.handle message
      end
    end
  end
end
