require 'cgi'

module Mab
  module Core
    class Error < StandardError; end
    class Tag
      def initialize(name, options, context)
        @name = name
        @options = options
        @context = context
        @done = false
        @content = false
      end

      def attributes
        @attributes ||= {}
      end

      def merge_attributes(attrs)
        if defined?(@attributes)
          @attributes.merge!(attrs)
        else
          @attributes = attrs
        end
      end

      def method_missing(name, content = nil, attrs = nil, &blk)
        name = name.to_s

        if name[-1] == ?!
          attributes[:id] = name[0..-2]
        else
          if attributes.has_key?(:class)
            attributes[:class] += " #{name}"
          else
            attributes[:class] = name
          end
        end

        insert(content, attrs, &blk)
      end

      def insert(content = nil, attrs = nil, &blk)
        raise Error, "This tag is already closed" if @done

        if content.is_a?(Hash)
          attrs = content
          content = nil
        end

        merge_attributes(attrs) if attrs

        if block_given?
          before = @context.size
          res = yield
          if @context.size == before
            @content = res.to_s
          else
            @content = nil
            @context << "</#{@name}>"
          end
          @done = true
        elsif content
          @content = CGI.escapeHTML(content.to_s)
          @done = true
        elsif attrs
          @done = true
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
        res = "<#{@name}#{attrs_to_s}"
        res << (@options[:xml] && @content == false ? ' />' : '>')
        res << "#{@content}</#{@name}>" if @content
        res
      end
    end

    def tag!(name, content = nil, attrs = nil, &blk)
      ctx = @mab_context || raise(Error, "Tags can only be written within a `mab { }`-block")
      tag = Tag.new(name, mab_options, ctx)
      ctx << tag
      tag.insert(content, attrs, &blk)
    end

    def text!(str)
      ctx = @mab_context || raise(Error, "Text can only be written within a `mab { }`-block")
      ctx << str
    end

    def text(str)
      text! CGI.escapeHTML(str.to_s)
    end

    def mab(&blk)
      prev = defined?(@mab_context) && @mab_context
      ctx = @mab_context = mab_options[:context].new
      res = instance_eval(&blk) if block_given?
      ctx.empty? ? res : ctx.join
    ensure
      @mab_context = prev
    end

    def mab_options
      @mab_options ||= {:context => Array}
    end

    module XML
      include Core

      def mab_options
        @mab_options ||= super.update(:xml => true)
      end
    end

    module HTMLDefiners
      def define_tag(meth, tag)
        class_eval <<-EOF
          def #{meth}(content = "", attrs = {}, &blk)
            if content.is_a?(Hash)
              attrs = content
              content = ""
            end
            tag!(:#{tag}, content.to_s, attrs, &blk)
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
          def #{meth}(attrs = {})
            if !attrs.is_a?(Hash) || block_given?
              raise Error, "#{meth} doesn't allow content"
            end
            tag!(:#{tag}, attrs)
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
      include Core

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

