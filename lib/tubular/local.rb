module Tubular
  class LocalFile
    def initialize(pieces_count)
      @have = [false] * pieces_count
      @file = File.open('download.download', 'wb')
    end

    def write(index, offset, buffers)
      @file.seek(offset, IO::SEEK_SET)
      buffers.each { |buffer| @file.write(buffer) }
      @have[index] = true
    end

    def have?(index, offset)
      @have[index]
    end

    def next_missing
      @have.index(false)
    end
  end
end
