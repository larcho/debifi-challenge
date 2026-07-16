require "test_helper"

class UserSignUpTest < ActionDispatch::IntegrationTest
  # Valid credentials reused across the happy-path and duplicate-email tests.
  VALID_EMAIL = "new.user@example.com".freeze
  VALID_PASSWORD = "password123".freeze

  def sign_up_params(overrides = {})
    {
      user: {
        email: VALID_EMAIL,
        password: VALID_PASSWORD,
        password_confirmation: VALID_PASSWORD
      }.merge(overrides)
    }
  end

  test "signing up with valid details creates the user and logs them in" do
    assert_difference "User.count", 1 do
      post user_registration_path, params: sign_up_params
    end

    assert_redirected_to root_path
    follow_redirect!
    assert_match "Logged in as #{VALID_EMAIL}", response.body
  end

  test "signing up with an invalid email is rejected" do
    assert_no_difference "User.count" do
      post user_registration_path, params: sign_up_params(email: "not-an-email")
    end

    assert_match "is invalid", response.body
  end

  test "signing up with a blank email is rejected" do
    assert_no_difference "User.count" do
      post user_registration_path, params: sign_up_params(email: "")
    end

    assert_match "can&#39;t be blank", response.body
  end

  test "signing up with mismatched password confirmation is rejected" do
    assert_no_difference "User.count" do
      post user_registration_path, params: sign_up_params(password_confirmation: "different")
    end

    assert_match "doesn&#39;t match Password", response.body
  end

  test "signing up with a password shorter than the minimum is rejected" do
    assert_no_difference "User.count" do
      post user_registration_path, params: sign_up_params(password: "short", password_confirmation: "short")
    end

    assert_match "too short", response.body
  end

  test "signing up with an already registered email is rejected" do
    User.create!(email: VALID_EMAIL, password: VALID_PASSWORD)

    assert_no_difference "User.count" do
      post user_registration_path, params: sign_up_params
    end

    assert_match "has already been taken", response.body
  end
end
