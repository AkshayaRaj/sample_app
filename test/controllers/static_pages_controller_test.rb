require 'test_helper'

class StaticPagesControllerTest < ActionController::TestCase

  def setup
    @base_title="ROR sample app"
  end

  test "should get home" do
    get :home
    assert_response :success
    assert_select "title" , "Home | #{@base_title}"
  end

  test "should get help" do
    get :help
    assert_response :success
    assert_select "title", "Help | #{@base_title}"
  end

  test "should get the about page" do
      get :about
      assert_select "title", "About | #{@base_title}"
      assert_response :success
    end

  test "should get to the contact page" do
    get :contact
    assert_select "title", "Contact | #{@base_title}"
    assert_response :success
  end
  
end
