require 'celluloid/autostart'
require 'celluloid/io'

require 'tubular/protocol'

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

      # Link the connection so that, if it dies, the peer dies as well.
      @connection = Connection.new_link(Actor.current, @host, @port, @environment)

      # Initially we know nothing about which pieces the peer has.  The other
      # peer will inform us either by a bitfield message or by a series of have
      # messages.
      @piece_map = Bitfield.empty(@environment[:torrent].pieces.length)

      # Queue of request messages to send to the peer. These are all generated
      # at once, but sent sequentially after each block is received.
      @request_queue = []
    end

    def connect
      @connection.connect

      self.am_interested = true

      every(30) do
        if (Time.now - @last_message_time) >= 30
          Tubular.logger.debug "Sending keepalive"
          @connection.send_message Protocol::Message.new(:keep_alive)
        end
      end
    end

    def handle(message)
      if message.type != :piece
        Tubular.logger.debug "Message: #{message}"
      end

      @last_message_time = Time.now

      case message.type
      when :keep_alive
        @connection.send_message Protocol::Message.new(:keep_alive)
      when :choke
        @choked = true
      when :unchoke
        @choked = false

        # Once we are unchoked, immediately request a piece.
        # TODO: Actually get pieces we want...
        request_piece(0)
        if req = @request_queue.shift
          @connection.send_message(req)
        end
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
        # TODO: Implement
      when :piece
        Tubular.logger.debug "Got piece index=#{message.payload[:index]} begin=#{message.payload[:begin]}"

        # Once we receive a piece, request the next one
        if req = @request_queue.shift
          @connection.send_message(req)
        end
      when :cancel
        # TODO: Implement
      when :port
        # TODO: Implement
      end
    end

    def am_interested=(interest)
      @am_interested = interest
      message_type = interest ? :interested : :notinterested
      message = Protocol::Message.new(message_type)
      @connection.send_message(message)
    end

    def am_choking=(choking)
      @am_choking = choking
      message_type = choking ? :choke : :unchoke
      message = Protocol::Message.new(message_type)
      @connection.send_message(message)
    end

    def request_piece(index)
      piece_length = @environment[:torrent].piece_length

      num_blocks = (piece_length + REQUEST_LENGTH - 1) / REQUEST_LENGTH
      (0..(num_blocks - 1)).each do |idx|
        start = idx * REQUEST_LENGTH

        length = REQUEST_LENGTH
        if start + length > piece_length
          length = piece_length - start
        end

        req = Protocol::Message.new(:request, index: index, begin: start, length: length)
        @request_queue << req
      end
    end
  end

  class Connection
    include Celluloid::IO
    include Protocol

    def initialize(sink, host, port, environment)
      @sink = sink
      @host, @port = host, port
      @environment = environment
    end

    def connect
      @socket = TCPSocket.new(@host, @port)

      send_handshake
      recv_handshake

      async.run
    end

    def run
      loop do
        message = recv_message
        @sink.handle message
      end
    end
  end
end
