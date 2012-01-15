require 'mab'

def mab(&blk)
  Mab::PrettyBuilder.new({}, self, &blk)
end

