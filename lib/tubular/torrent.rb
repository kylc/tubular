module Tubular
  class Torrent < Hash
    def self.open(file_name)
      root = Bencode.parse_from_file(file_name)
      Torrent.new(root)
    end

    attr_reader :root

    def initialize(root)
      super.update(root)
    end
  end
end
