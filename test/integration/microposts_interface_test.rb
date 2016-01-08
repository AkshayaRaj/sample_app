require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:akshaya)
  #  log_in_as(@user)
  end

  test "micropost interface" do
    log_in_as(@user)
    get root_path
    assert_select 'div.pagination'
    #Invalid submission
    assert_no_difference 'Micropost.count',1  do
      post microposts_path, micropost: {content: ""}
    end
    assert_select 'div#error_explanation'
    #valid submission
    content = "This is a test post"
    assert_difference 'Micropost.count',1 do
      post microposts_path, micropost: {content: content}
    end
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body
    #delete a post
    assert_select 'a', text: 'delete'
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference 'Micropost.count',-1 do
      delete micropost_path(first_micropost)
    end
    # Visit a different user
    get user_path(users(:archer))
    assert_select 'a',text: 'delete', count:  0

  end
end
