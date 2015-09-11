require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  def setup
    @user=users(:akshaya)
  end

  test "unsuccessfull edit " do
    log_in_as(@user,remember_me: '0')
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), user: {  name: " ",
                                    email: "foo@invalid",
                                    password: "foo",
                                    password_confirmation: "bar"}
    assert_template 'users/edit'
  end


  test "successful edit with friendly forwarding only once" do
    get edit_user_path(@user)
    log_in_as(@user,remember_me: '0')
    assert_redirected_to edit_user_path(@user)
    follow_redirect!
    assert_template 'users/edit'
    name="anant shiv"
    email="anant@gmail.com"
    patch user_path(@user), user: {  name: name,
                                    email: email,
                                    password: "",
                                    password_confirmation: ""}
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name, @user.name
    assert_equal email, @user.email
  end



end
