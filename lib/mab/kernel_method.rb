require 'mab'

def mab(&blk)
  Mab::PrettyBuilder.new({}, self, &blk).to_s
end

