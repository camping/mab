require 'cgi'

module Mab
  module Mixin
    class Error < StandardError; end
    class Tag
      attr_accessor :_name, :_content, :_attributes, :_block, :_has_content
      attr_reader :_options, :_context, :_instance

      def initialize(name, options, context, instance = nil)
        @_name = name
        @_options = options
        @_context = context
        @_instance = instance
        @_done = false

        @_content = nil
        @_has_content = nil

        @_attributes = {}

        @_pos = @_context.size
      end

      def _block
        return @_block unless block_given?
        current = @_block
        @_block = proc { yield current }
      end

      def _merge_attributes(*args)
        args.each do |attrs|
          @_attributes.merge!(attrs)
        end
      end

      def method_missing(name, *args, &blk)
        name = name.to_s

        if name[-1] == ?!
          @_attributes[:id] = name[0..-2]
        else
          if @_attributes.has_key?(:class)
            @_attributes[:class] += " #{name}"
          else
            @_attributes[:class] = name
          end
        end

        _insert(*args, &blk)
      end

      def _insert(*args, &blk)
        raise Error, "This tag is already closed" if @_done

        if !args.empty? && !args[0].is_a?(Hash)
          content = args.shift
          raise Error, "Tag doesn't allow content" if @_has_content == false
          @_has_content = true
        end

        if content
          @_content = CGI.escapeHTML(content.to_s)
          @_done = true
        end

        if !args.empty?
          _merge_attributes(*args)
          @_done = true
        end

        if block_given?
          raise Error, "Tag doesn't allow content" if @_has_content == false
          @_has_content = true
          @_block = blk
          @_done = true
        end

        if @_content && @_block
          raise Error, "Both content and _block is not allowed"
        end

        @_instance.mab_done(self) if @_done

        if @_block
          before = @_context.children
          res = @_block.call

          if before >= @_context.children
            @_content = res.to_s
          else
            # Turn the node into just an opening tag.
            @_has_content = false
            @_instance.mab_insert("</#{@_name}>")
          end
        end

        self
      end

      def to_ary() nil end
      def to_str() to_s end

      def _attrs_to_s
        @_attributes.inject("") do |res, (name, value)|
          if value
            value = (value == true) ? name : CGI.escapeHTML(value.to_s)
            res << " #{name}=\"#{value}\""
          end
          res
        end
      end

      def to_s
        if !@_context.joining? && @_context[@_pos]
          @_context[@_pos] = nil
          @_context.children -= 1
        end

        res = "<#{@_name}#{_attrs_to_s}"
        res << (@_options[:xml] && !@_block && !@_has_content ? ' />' : '>')
        res << "#{@_content}</#{@_name}>" if @_has_content
        res
      end
    end

    class Context < Array
      attr_accessor :children, :options

      def initialize
        @children = 0
        @joining = false
        @options = {}
      end

      def <<(str)
        @children += 1
        super(str)
      end

      def join(*)
        @joining = true
        super
      end

      def joining?
        @joining
      end
    end

    def mab_tag(name)
      ctx = @mab_context || raise(Error, "Tags can only be written within a `mab { }`-block")
      tag = Tag.new(name, mab_options, ctx, self)
      mab_insert(tag)
      tag
    end

    def tag!(name, *args, &blk)
      mab_tag(name)._insert(*args, &blk)
    end

    def text!(str)
      mab_insert(str)
    end

    def text(str)
      text! CGI.escapeHTML(str.to_s)
    end

    def mab(&blk)
      prev = defined?(@mab_context) && @mab_context
      ctx = @mab_context = Context.new
      res = instance_eval(&blk)
      ctx.empty? ? res : ctx.join
    ensure
      @mab_context = prev
    end

    def mab_insert(tag)
      ctx = @mab_context || raise(Error, 'mab { }-block required')
      ctx << tag
    end

    def mab_done(tag)
    end

    def mab_options
      @mab_options ||= {}
    end

    module XML
      include Mixin

      def mab_options
        @mab_options ||= super.update(:xml => true)
      end
    end

    module HTMLDefiners
      def define_tag(meth, tag)
        class_eval <<-EOF
          def #{meth}(*args, &blk)
            tag = mab_tag(:#{tag})
            tag._has_content = true
            tag._insert(*args, &blk)
          end
        EOF
      end

      def define_tags(*tags)
        tags.flatten.each do |tag|
          define_tag(tag, tag)
        end
      end

      def define_empty_tag(meth, tag)
        class_eval <<-EOF
          def #{meth}(*args, &blk)
            tag = mab_tag(:#{tag})
            tag._has_content = false
            tag._insert(*args, &blk)
          end
        EOF
      end

      def define_empty_tags(*tags)
        tags.flatten.each do |tag|
          define_empty_tag(tag, tag)
        end
      end
    end

    module HTML5
      extend HTMLDefiners
      include Mixin

      define_tags %w[a abbr acronym address applet article aside audio b
        basefont bdi bdo big blockquote body button canvas caption
        center cite code colgroup datalist dd del details dfn dir div dl
        dt em fieldset figcaption figure font footer form frame frameset
        h1 h2 h3 h4 h5 h6 head header hgroup html i iframe ins kbd label
        legend li link map mark math menu meter nav noframes noscript
        object ol optgroup option output p pre progress q rp rt ruby s
        samp script section select small span strike strong style sub
        summary sup svg table tbody td textarea tfoot th thead time
        title tr tt u ul var video xmp]

      define_empty_tags %w[base link meta hr br wbr img embed param source
        track area col input keygen command]

      def doctype!
        text! '<!DOCTYPE html>'
      end
    end

    module XHTML5
      include HTML5
      include XML
    end
  end
end

