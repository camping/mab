require 'helper'

class TestMabKernelMethod < MiniTest::Unit::TestCase
  def test_kernel_method
    require 'mab/kernel_method'
    @a = 1
    assert_equal "<p>\n  <p>3</p>\n</p>", mab { p { p { @a + 2 } } }
  end
end

