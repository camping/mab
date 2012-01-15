require 'helper'

class TestMabKernelMethod < MiniTest::Unit::TestCase
  def test_kernel_method
    require 'mab/kernel_method'
    @a = 1
    assert_equal "<p>3</p>", mab { p @a + 2 }.to_s
  end
end

