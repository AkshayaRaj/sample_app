require 'test_helper'

class StaticPagesControllerTest < ActionController::TestCase
  test "should get home" do
    get :home    
    assert_response :success
    assert_select "title" , "ROR sample app"
  end

  test "should get help" do
    get :help
    assert_response :success
    assert_select "title", "Help | ROR sample app"
  end

  test "should get the about page" do
      get :about
      assert_select "title", "About | ROR sample app"
      assert_response :success
    end
end
