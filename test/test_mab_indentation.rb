require 'helper'

class TestMabIndentation < MiniTest::Unit::TestCase
  def setup
    super
    @obj = Object.new
    @obj.extend Mab::Mixin
    @obj.extend Mab::Indentation
  end

  def test_simple
    assert_equal "<p>Hello</p>", @obj.mab { tag! :p, 'Hello' }
  end

  def test_block
    assert_equal "<p>\n  Hello\n</p>", @obj.mab { tag!(:p) { text 'Hello' } }
  end

  def test_chaining
    res = <<HTML.strip
<p class="hello">
  <br>
</p>
HTML

    assert_equal res, @obj.mab {
      tag!(:p).hello do
        tag! :br
      end
    }
  end

  def test_reindent
    res = <<HTML.strip
<p>
  Hello
  World
</p>
HTML

    assert_equal res, @obj.mab {
      tag! :p do
        reindent! "Hello\nWorld"
      end
    }
  end

  def test_stringification
    res = <<HTML.strip
<h1>
  <div><span>Hello</span> | <span>Hello</span></div>
</h1>
HTML

    assert_equal res, @obj.mab {
      tag!(:h1) do
        s = tag!(:span, 'Hello')
        tag!(:div) do
          [s, s].join(' | ')
        end
      end

    }
  end
end

