module Mab
  module Indentation
    def mab_insert(ctx, str)
      if i = ctx.options[:indentation]
        super(ctx, [$/ + "  " * i, str])
      else
        ctx.options[:indentation] = 0
        super
      end
    end

    def mab_done(ctx, tag)
      if blk = tag._block
        tag._block = proc do
          begin
            ctx.options[:indentation] += 1
            blk.call
          ensure
            ctx.options[:indentation] -= 1
          end
        end
      end
      super
    end

    def reindent!(str)
      str.split(/\r?\n/).each do |s|
        text! s
      end
    end
  end
end

