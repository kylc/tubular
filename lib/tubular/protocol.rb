require 'tubular/bitfield'
require 'tubular/buffer'

module Tubular
  module Protocol
    class Message < Struct.new(:type, :payload)
    end

    def send_handshake
      buf = Buffer.new
      buf.put_u8(19)
      buf.put_string("BitTorrent protocol")
      buf.put([0] * 8)
      buf.put_string(@environment[:torrent].info_hash)
      buf.put_string(@environment[:peer_id])

      @socket.write buf.data
    end

    def recv_handshake
      pstrlen = @socket.readpartial(1).unpack('C')[0]
      buf = Buffer.new(@socket.read(48 + pstrlen))

      Message.new :handshake, pstr: buf.get_string(pstrlen),
        reserved: buf.get(8), info_hash: buf.get(20), peer_id: buf.get(20)
    end

    def send_message(message)
      buf = Buffer.new

      case message.type
      when :keep_alive
        buf.put_u32(0)
      when :choke
        buf.put_u32(1)
        buf.put_u8(0)
      when :unchoke
        buf.put_u32(1)
        buf.put_u8(1)
      when :interested
        buf.put_u32(1)
        buf.put_u8(2)
      when :notinterested
        buf.put_u32(1)
        buf.put_u8(3)
      when :have
        buf.put_u32(5)
        buf.put_u8(4)
        buf.put_u32(message[:piece_index])
      when :bitfield
        # TODO
      when :request
        buf.put_u32(13)
        buf.put_u8(6)
        [:index, :begin, :length].each { |k| buf.put_u32(message.payload[k]) }
      when :piece
        # TODO
      when :cancel
        buf.put_u32(13)
        buf.put_u8(8)
        [:index, :begin, :length].each { |k| buf.put_u32(message.payload[k]) }
      when :port
        buf.put_u32(3)
        buf.put_u8(9)
        buf.put_u32(message[:listen_port])
      end

      @socket.write buf.data
    end

    def recv_message
      buf = Buffer.new(@socket.read(4))
      len = buf.get_u32

      buf.put_raw(@socket.read(len))

      if len == 0
        Message.new :keep_alive
      else
        id = buf.get_u8

        case id
        when 0
          Message.new :choke
        when 1
          Message.new :unchoke
        when 2
          Message.new :interested
        when 3
          Message.new :not_interested
        when 4
          Message.new :have, piece_index: buf.get_u32
        when 5
          Message.new :bitfield, bitfield: Bitfield.new(buf.get(len - 1))
        when 6
          Message.new :request, index: buf.get_u32, begin: buf.get_u32, length: buf.get_u32
        when 7
          Message.new :piece, index: buf.get_u32, begin: buf.get_u32, block: buf.get(len - 9)
        when 8
          Message.new :cancel, index: buf.get_u32, begin: buf.get_u32, length: buf.get_u32
        when 9
          Message.new :port, listen_port: buf.get_u32
        end
      end
    end
  end
end
