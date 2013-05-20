require 'digest'

module Tubular
  class Torrent < Hash
    def self.open(file_name)
      root = Bencode.parse_from_file(file_name)
      Torrent.new(root)
    end

    def initialize(root)
      super.update(root)

      @digest = Digest::SHA1.new
    end

    def info
      self['info']
    end

    def piece_length
      info['piece length'].to_i
    end

    def pieces
      info['pieces'].chars.each_slice(20).map(&:join)
    end

    def info_hash
      @digest.digest(Bencode::encode(self['info']))
    end
  end
end
