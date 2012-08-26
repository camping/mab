require 'helper'

class TestMabBuilder < MiniTest::Unit::TestCase
  def test_assigns
    b = Mab::Builder.new(:title => 'Mab') do
      title @title
    end

    assert_equal '<title>Mab</title>', b.to_s
  end

  def test_capture
    b = Mab::Builder.new do
      %w[name address].map do |key|
        mab do
          p key
        end
      end.join('<br>')
    end

    assert_equal "<p>name</p><br><p>address</p>", b.to_s
  end

  def test_helper
    obj = Class.new {
      def initialize
        @a = 1
        @b = 2
      end

      def c; @a + @b end
    }.new

    b = Mab::Builder.new({}, obj) do
      p @a
      p @b
      p c
    end

    assert_equal '<p>1</p><p>2</p><p>3</p>', b.to_s
  end

  def test_pretty
    b = Mab::PrettyBuilder.new do
      doctype!
      html do
        body do
          h1 "Nice"
        end
      end
    end

    assert_equal "<!DOCTYPE html>\n<html>\n  <body>\n    <h1>Nice</h1>\n  </body>\n</html>", b.to_s
  end
end

