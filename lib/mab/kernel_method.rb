require 'mab'

def mab(&blk)
  Mab::Builder.new({}, self, &blk)
end

