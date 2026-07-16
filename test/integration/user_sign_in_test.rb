require "test_helper"

class UserSignInTest < ActionDispatch::IntegrationTest
  EMAIL = "member@example.com".freeze
  PASSWORD = "password123".freeze

  # A page that requires authentication, used to probe whether a session is
  # actually signed in.
  PROTECTED_PATH = "/plans".freeze

  setup do
    @user = User.create!(email: EMAIL, password: PASSWORD)
  end

  def sign_in_with(email: EMAIL, password: PASSWORD, remember_me: nil)
    params = { user: { email: email, password: password } }
    params[:user][:remember_me] = remember_me unless remember_me.nil?
    post user_session_path, params: params
  end

  def assert_signed_in
    get PROTECTED_PATH
    assert_response :success, "expected an authenticated session to reach the protected page"
  end

  def assert_signed_out
    get PROTECTED_PATH
    assert_redirected_to new_user_session_path,
      "expected an unauthenticated session to be redirected to sign in"
  end

  # --- Happy path -----------------------------------------------------------

  test "valid credentials sign the user in" do
    sign_in_with

    assert_redirected_to root_path
    follow_redirect!
    assert_match "Logged in as #{EMAIL}", response.body
    assert_signed_in
  end

  test "email lookup is case-insensitive" do
    sign_in_with(email: EMAIL.upcase)

    assert_redirected_to root_path
    assert_signed_in
  end

  test "surrounding whitespace in the email is ignored" do
    sign_in_with(email: "  #{EMAIL}  ")

    assert_redirected_to root_path
    assert_signed_in
  end

  # --- Invalid credentials --------------------------------------------------

  test "wrong password is rejected" do
    sign_in_with(password: "wrong-password")

    assert_response :success
    assert_match "Invalid Email or password.", response.body
    assert_signed_out
  end

  test "unknown email is rejected" do
    sign_in_with(email: "nobody@example.com")

    assert_response :success
    assert_match "Invalid Email or password.", response.body
    assert_signed_out
  end

  test "blank email is rejected" do
    sign_in_with(email: "")

    assert_response :success
    assert_signed_out
  end

  test "blank password is rejected" do
    sign_in_with(password: "")

    assert_response :success
    assert_signed_out
  end

  # --- Remember me ----------------------------------------------------------

  test "remember me sets a persistent cookie" do
    sign_in_with(remember_me: "1")

    assert cookies["remember_user_token"].present?,
      "expected a remember_user_token cookie to be set"
  end

  test "without remember me no persistent cookie is set" do
    sign_in_with(remember_me: "0")

    assert_not cookies["remember_user_token"].present?,
      "did not expect a remember_user_token cookie"
  end

  # --- Sign out & auth guard ------------------------------------------------

  test "signing out clears the session" do
    sign_in_with
    assert_signed_in

    delete destroy_user_session_path
    assert_redirected_to root_path
    follow_redirect!
    assert_no_match "Logged in as", response.body
    assert_signed_out
  end

  test "protected pages redirect guests to the sign in form" do
    get PROTECTED_PATH

    assert_redirected_to new_user_session_path
    follow_redirect!
    assert_match "You need to sign in or sign up before continuing.", response.body
  end
end
