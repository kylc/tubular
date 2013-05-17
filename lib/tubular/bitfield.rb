module Tubular
    class Bitfield
      attr_reader :length

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
