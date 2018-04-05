module Mab
  module Component
    def helper(name, &blk)
      define_method(name) do
        obj = self
        proc { |*args| instance_exec(obj, *args, &blk) }
      end
    end

    def render(&blk)
      helper(:to_mab_proc, &blk)
    end
  end
end

