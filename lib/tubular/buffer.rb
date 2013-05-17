module Tubular
  class Buffer
    attr_reader :data

    def initialize(data = "")
      @data = data
    end

    def get_u8
      get(1).unpack('C')[0]
    end

    def put_u8(v)
      @data << [v].pack('C')
    end

    def get_u32
      get(4).unpack('N')[0]
    end

    def put_u32(v)
      @data << [v].pack('N')
    end

    def get_string(n)
      get(n)
    end

    def put_string(v)
      @data << [v].pack('a*')
    end

    def get(n)
      @data.slice!(0, n)
    end

    def put(vs)
      @data << vs.pack('C*')
    end

    def put_raw(v)
      @data << v
    end
  end
end
