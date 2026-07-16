require "test_helper"

class UserAccountEditTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  EMAIL = "member@example.com".freeze
  PASSWORD = "password123".freeze

  setup do
    @user = User.create!(email: EMAIL, password: PASSWORD)
    sign_in @user
  end

  def update_account(params)
    put user_registration_path, params: { user: params }
  end

  # --- Access control -------------------------------------------------------

  test "guests cannot open the account edit page" do
    sign_out @user

    get edit_user_registration_path
    assert_redirected_to new_user_session_path
  end

  test "signed-in user can open the account edit page" do
    get edit_user_registration_path
    assert_response :success
  end

  # --- Updating the email ---------------------------------------------------

  test "email is updated with the correct current password" do
    update_account(email: "renamed@example.com", current_password: PASSWORD)

    assert_redirected_to root_path
    assert_equal "renamed@example.com", @user.reload.email
    follow_redirect!
    assert_match "Your account has been updated successfully.", response.body
  end

  test "email update is rejected with a wrong current password" do
    update_account(email: "renamed@example.com", current_password: "wrong-password")

    assert_match "is invalid", response.body
    assert_equal EMAIL, @user.reload.email
  end

  test "email update is rejected with a blank current password" do
    update_account(email: "renamed@example.com", current_password: "")

    assert_match "can&#39;t be blank", response.body
    assert_equal EMAIL, @user.reload.email
  end

  test "email update is rejected when the new email is invalid" do
    update_account(email: "not-an-email", current_password: PASSWORD)

    assert_match "is invalid", response.body
    assert_equal EMAIL, @user.reload.email
  end

  test "email update is rejected when the email is already taken" do
    User.create!(email: "taken@example.com", password: PASSWORD)

    update_account(email: "taken@example.com", current_password: PASSWORD)

    assert_match "has already been taken", response.body
    assert_equal EMAIL, @user.reload.email
  end

  # --- Updating the password ------------------------------------------------

  test "password is updated with the correct current password" do
    new_password = "new-password456"
    update_account(
      password: new_password,
      password_confirmation: new_password,
      current_password: PASSWORD
    )

    assert_redirected_to root_path
    follow_redirect!
    assert_match "Your account has been updated successfully.", response.body

    # The new password actually authenticates.
    sign_out @user
    post user_session_path, params: { user: { email: EMAIL, password: new_password } }
    assert_redirected_to root_path
  end

  test "password update is rejected when the confirmation does not match" do
    update_account(
      password: "new-password456",
      password_confirmation: "different",
      current_password: PASSWORD
    )

    assert_match "doesn&#39;t match Password", response.body
    assert @user.reload.valid_password?(PASSWORD), "password should be unchanged"
  end

  test "password update is rejected when the password is too short" do
    update_account(
      password: "short",
      password_confirmation: "short",
      current_password: PASSWORD
    )

    assert_match "too short", response.body
    assert @user.reload.valid_password?(PASSWORD), "password should be unchanged"
  end

  # --- Cancelling the account -----------------------------------------------

  test "cancelling the account deletes the user and signs them out" do
    assert_difference "User.count", -1 do
      delete user_registration_path
    end

    assert_redirected_to root_path
    follow_redirect!
    assert_match "Bye! Your account has been successfully cancelled.", response.body
    assert_not User.exists?(@user.id)
  end
end
