module Tubular
    class Bitfield
      attr_reader :length

      def self.empty(length_in_bits)
        bytes = (length_in_bits / 8.0).ceil
        data = ([0] * bytes).pack('C*')
        Bitfield.new(data)
      end

      def initialize(data)
        @data = data.unpack('C*')
        @length = data.length * 8
      end

      def [](position)
        @data[position / 8] & (128 >> (position % 8)) > 0
      end

      def []=(position, val)
        if val
          @data[position / 8] |= (128 >> (position % 8))
        else
          @data[position / 8] ^= (128 >> (position % 8))
        end
      end
    end
end
