module Mab
  module Indentation
    class Context < Mixin::Context
      def initialize
        @indentation = 0
        super
      end

      def with_indent
        @indentation += 1
        yield
      ensure
        @indentation -= 1
      end

      def <<(str)
        indent = if empty?
          "  " * @indentation
        else
          $/ + "  " * @indentation
        end
        super([indent, str])
      end
    end

    def mab_options
      @mab_options ||= super.update(:context => Context)
    end

    def mab_done(tag)
      if blk = tag.block
        tag.block = proc { @mab_context.with_indent(&blk) }
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

