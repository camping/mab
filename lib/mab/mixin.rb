require 'cgi'

module Mab
  module Mixin
    class Error < StandardError; end
    class Tag
      attr_accessor :name, :content, :attributes, :block, :empty
      attr_reader :options, :context, :instance

      def initialize(name, options, context, instance = nil)
        @name = name
        @options = options
        @context = context
        @instance = instance
        @done = false

        @content = nil
        @attributes = {}

        @pos = @context.size
      end

      def block
        return @block unless block_given?
        current = @block
        @block = proc { yield current }
      end

      def merge_attributes(*args)
        args.each do |attrs|
          @attributes.merge!(attrs)
        end
      end

      def method_missing(name, *args, &blk)
        name = name.to_s

        if name[-1] == ?!
          @attributes[:id] = name[0..-2]
        else
          if @attributes.has_key?(:class)
            @attributes[:class] += " #{name}"
          else
            @attributes[:class] = name
          end
        end

        insert(*args, &blk)
      end

      def insert_first(*args, &blk)
        @content = false if args.empty? || args[0].is_a?(Hash)
        insert(*args, &blk)
      end

      def insert(*args, &blk)
        raise Error, "This tag is already closed" if @done

        if !args.empty? && !args[0].is_a?(Hash)
          content = args.shift
          raise Error, "Tag doesn't allow content" if @content == false
        end

        if content
          @content = CGI.escapeHTML(content.to_s)
          @done = true
        end

        if !args.empty?
          merge_attributes(*args)
          @done = true
        end

        if block_given?
          @block = blk
          @done = true
        end

        if @content && @block
          raise Error, "Both content and block is not allowed"
        end

        @instance.mab_done(self) if @done

        if @block
          before = @context.children
          res = @block.call

          if before >= @context.children
            @content = res.to_s
          else
            @content = false
            @instance.mab_insert("</#{@name}>")
          end
        end

        self
      end

      def to_ary() nil end
      def to_str() to_s end

      def attrs_to_s
        attributes.inject("") do |res, (name, value)|
          if value
            value = (value == true) ? name : CGI.escapeHTML(value.to_s)
            res << " #{name}=\"#{value}\""
          end
          res
        end
      end

      def to_s
        if !@context.joining? && @context[@pos]
          @context[@pos] = nil
          @context.children -= 1
        end

        res = "<#{@name}#{attrs_to_s}"
        res << (@options[:xml] && (!@block && @content == false) ? ' />' : '>')
        res << "#{@content}</#{@name}>" if @content != false
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

    def tag!(name, *args, &blk)
      ctx = @mab_context || raise(Error, "Tags can only be written within a `mab { }`-block")
      tag = Tag.new(name, mab_options, ctx, self)
      mab_insert(tag)
      tag.insert_first(*args, &blk)
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
            args.unshift nil if args.empty? || args[0].is_a?(Hash)
            tag!(:#{tag}, *args, &blk)
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
          def #{meth}(*args)
            if (!args.empty? && !args[0].is_a?(Hash)) || block_given?
              raise Error, "#{meth} doesn't allow content"
            end
            tag!(:#{tag}, *args)
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

