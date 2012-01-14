module Mab
  module Indentation
    class Context < Array
      def initialize
        @indentation = 0
      end

      def with_indent
        @indentation += 1
        yield
      ensure
        @indentation -= 1
      end

      def <<(str)
        if empty?
          super("  " * @indentation)
        else
          super($/ + "  " * @indentation)
        end
        super(str)
      end
    end

    def mab_options
      @mab_options ||= super.update(:context => Context)
    end

    def tag!(*, &blk)
      if blk
        super do
          @mab_context.with_indent(&blk)
        end
      else
        super
      end
    end
  end
end

