require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test "full title helper" do
    assert_equal full_title,         "ROR sample app"
    assert_equal full_title("Help"), "Help | ROR sample app"
  end
end
