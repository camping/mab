module Mab
  module Indentation
     def mab_insert(str)
      if i = @mab_context.options[:indentation]
        super([$/ + "  " * i, str])
      else
        @mab_context.options[:indentation] = 0
        super
      end
    end

    def mab_done(tag)
      if blk = tag._block
        tag._block = proc do
          begin
            @mab_context.options[:indentation] += 1
            blk.call
          ensure
            @mab_context.options[:indentation] -= 1
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

