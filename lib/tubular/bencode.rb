module Tubular
  module Bencode
    class Parser
      def parse_from_file(source)
        return parse(source.read) if source.respond_to?(:read)
        return File.read(source) if source.respond_to?(:to_s)
        raise ArgumentError
      end

      def parse_from_string(string)
        parse(StringIO.new(string))
      end

      private

      def parse(io)
        leader = io.getc

        case leader
        when 'i'
          parse_int(io)
        when 'l'
          parse_list(io)
        when 'd'
          parse_dict(io)
        else
          io.ungetc(leader)
          parse_string(io)
        end
      end

      def parse_int(io)
        num = io.readline('e')[0..-2].to_i
      end

      def parse_string(io)
        length = 0
        while (char = io.getc) != ':'
          length = length * 10 + char.to_i
        end

        value = io.gets(length)
      end

      def parse_list(io)
        elements = []

        while (leader = io.getc) != 'e'
          io.ungetc(leader)
          elements << parse(io)
        end

        elements
      end

      def parse_dict(io)
        dict = {}

        while (leader = io.getc) != 'e'
          io.ungetc(leader)

          key, val = parse(io), parse(io)
          dict[key] = val
        end

        dict
      end
    end
  end
end
