require_relative 'helper'

class TestMabComponent < Minitest::Test
  def setup
    super
    @obj = Object.new
    @obj.extend Mab::Mixin
    @obj.extend Mab::Mixin::HTML5
  end

  class Pagination
    extend Mab::Component

    attr_reader :title
    def initialize(title)
      @title = title
    end

    render do |obj|
      div do
        h2 obj.title
      end
    end
  end

  def test_basic_object
    assert_equal '<div><h2>Hello world</h2></div>', @obj.mab {
      call! Pagination.new("Hello world")
    }
  end
end

