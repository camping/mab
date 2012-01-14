require 'helper'

class TestMabIndentation < MiniTest::Unit::TestCase
  def setup
    super
    @obj = Object.new
    @obj.extend Mab::Core
    @obj.extend Mab::Indentation
  end

  def test_simple
    assert_equal '<p>Hello</p>', @obj.mab { tag! :p, 'Hello' }
  end

  def test_block
    assert_equal "<p>\n  Hello\n</p>", @obj.mab { tag!(:p) { text 'Hello' } }
  end
end

