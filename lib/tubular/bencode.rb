module Tubular
  class Bencode 
    class << self
      def parse_from_file(source)
        return parse(source) if source.respond_to?(:read)
        return parse(File.open(source.to_s)) if source.respond_to?(:to_s)
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
        num = io.gets('e').chop.to_i
      end

      def parse_string(io)
        length = io.gets(':').to_i
        value = io.read(length)
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
