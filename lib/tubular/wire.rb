module Tubular
  module Wire
    class Message < Struct.new(:type, :payload)
    end

    def send_handshake
      out = []
      out << 19
      out << "BitTorrent protocol"
      out << [0, 0, 0, 0, 0, 0, 0, 0]
      out << @environment[:torrent].info_hash
      out << @environment[:peer_id]

      @socket.write out.flatten.pack('Ca19C8a20a20')
    end

    def recv_handshake
      pstrlen = @socket.readbyte
      pstr = @socket.read pstrlen
      reserved = @socket.read(8)
      info_hash = @socket.read(20)
      peer_id = @socket.read(20)

      Message.new :handshake, pstr: pstr, reserved: reserved,
        info_hash: info_hash, peer_id: peer_id
    end

    def send_message
    end

    def recv_message
      len = @socket.readbyte

      if len == 0
        Message.new :keep_alive
      else
        id = @socket.readbyte

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
          Message.new :have, piece_index: w32
        when 5
          Message.new :bitfield, bitfield: read(len - 1)
        when 6
          Message.new :request, index: w32, begin: w32, length: w32
        when 7
          Message.new :piece, index: w32, begin: w32, block: read(len - 9)
        when 8
          Message.new :cancel, index: w32, begin: w32, length: w32
        when 9
          Message.new :port, listen_port: w32
        end
      end
    end

    private

    def read(len)
      @socket.read(len)
    end

    def w32
      @socket.read(4).unpack('N')
    end
  end
end
