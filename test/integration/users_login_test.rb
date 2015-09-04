require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  def setup
    @user=users(:akshaya)
  end

  test "login with invalid info" do
    get login_path
    assert_template 'sessions/new'
    post login_path, session: {email:"", password: ""}
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end

  test "login with valid info followed by logut" do
    get login_path
    post login_path, session: {email:@user.email, password: 'password'} # here session is the hash
    assert is_logged_in?
    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url
    #Simulate a user clicking a log out link on a second browser window after logging out on the first one
    delete logout_path
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path, count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end

  test "login with remembering" do
   log_in_as(@user,remember_me: '1')
   #assert_not_nil cookies['remember_token']
   assert_equal cookies['remember_token'], assigns(:user).remember_token
  # delete logout_path
  end

  test "login without remembering" do
    log_in_as(@user,remember_me: '0')
    assert_nil cookies['remember_token']
  #  delete logout_path
  end



end
