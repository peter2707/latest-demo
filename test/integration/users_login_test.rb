require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  def setup
    @users = users(:michael)
  end

  test "login with invalid information" do
    get login_path
    assert_template 'sessions/new'
    post login_path, params: { session: { email: "", password: "" } } 
    assert_template 'sessions/new'
    assert_not flash.empty? 
    get root_path
    assert flash.empty?
  end

  test "login with valid information followed by logout" do
    get login_path
    post login_path, params: { session: { email: @users.email, password: 'password' }}

    assert is_logged_in?
    assert_redirected_to @users
    follow_redirect!
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@users)
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url
    #Simulate a user clicking logout in a second window
    delete logout_path
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path, count: 0
    assert_select "a[href=?]", user_path(@users), count: 0
    end

    test "login with remember me" do
      log_in_as(@users, remember_me: '1')
      assert_not_empty cookies[:remember_token]
    end

    test "login without remember me" do
      #log in to set the cookie
      log_in_as(@users, remember_me: '1')
      #log in again and verify that the cookie is deleted
      log_in_as(@users, remember_me: '0')
      assert_empty cookies[:remember_token]
    end
end
