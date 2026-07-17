require "test_helper"

class PostsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @author = User.create!(email: "author@example.com", password: "password123")
    @other  = User.create!(email: "other@example.com", password: "password123")
    @post = @author.posts.create!(
      title: "The original title",
      html_body: "<p>Body content about ruby</p>"
    )
  end

  # --- Index (public) -------------------------------------------------------

  test "guests can view the index" do
    get posts_path
    assert_response :success
    assert_match @post.title, response.body
  end

  test "search filters posts by matching content" do
    other_post = @author.posts.create!(
      title: "An unrelated article",
      html_body: "<p>Nothing to see here</p>"
    )

    get posts_path, params: { search: { q: "ruby" } }

    assert_response :success
    assert_match @post.title, response.body
    assert_no_match other_post.title, response.body
  end

  # --- Authentication guards ------------------------------------------------

  test "guests are redirected from the new post form" do
    get new_post_path
    assert_redirected_to new_user_session_path
  end

  test "guests cannot create a post" do
    assert_no_difference "Post.count" do
      post posts_path, params: { post: { title: "Guest sneaks in", html_body: "<p>x</p>" } }
    end
    assert_redirected_to new_user_session_path
  end

  test "guests are redirected from a post's show page" do
    get post_path(@post)
    assert_redirected_to new_user_session_path
  end

  test "guests are redirected from the edit form" do
    get edit_post_path(@post)
    assert_redirected_to new_user_session_path
  end

  test "guests cannot destroy a post" do
    assert_no_difference "Post.count" do
      delete post_path(@post)
    end
    assert_redirected_to new_user_session_path
  end

  # --- Show -----------------------------------------------------------------

  test "signed-in users can view a post" do
    sign_in @other
    get post_path(@post)
    assert_response :success
    assert_match @post.title, response.body
  end

  # --- Create ---------------------------------------------------------------

  test "a signed-in user can create a valid post" do
    sign_in @author

    assert_difference "Post.count", 1 do
      post posts_path, params: { post: { title: "A brand new post", html_body: "<p>Hello</p>" } }
    end

    created = Post.order(:created_at).last
    assert_equal @author, created.author
    assert_redirected_to post_url(created)
    follow_redirect!
    assert_match "Post was created", response.body
  end

  test "a post with a blank title is rejected" do
    sign_in @author
    assert_no_difference "Post.count" do
      post posts_path, params: { post: { title: "", html_body: "<p>Hello</p>" } }
    end
    assert_match "can&#39;t be blank", response.body
  end

  test "a post with a too-short title is rejected" do
    sign_in @author
    assert_no_difference "Post.count" do
      post posts_path, params: { post: { title: "hi", html_body: "<p>Hello</p>" } }
    end
    assert_match "too short", response.body
  end

  test "a post with a too-long title is rejected" do
    sign_in @author
    assert_no_difference "Post.count" do
      post posts_path, params: { post: { title: "a" * 101, html_body: "<p>Hello</p>" } }
    end
    assert_match "too long", response.body
  end

  test "a post with a blank body is rejected" do
    sign_in @author
    assert_no_difference "Post.count" do
      post posts_path, params: { post: { title: "A valid title", html_body: "" } }
    end
    assert_match "can&#39;t be blank", response.body
  end

  # --- Edit / Update --------------------------------------------------------

  test "the author can open the edit form" do
    sign_in @author
    get edit_post_path(@post)
    assert_response :success
  end

  test "a user cannot open the edit form for someone else's post" do
    sign_in @other
    assert_raises(ActiveRecord::RecordNotFound) do
      get edit_post_path(@post)
    end
  end

  test "the author can update their post" do
    sign_in @author

    patch post_path(@post), params: { post: { title: "An updated title" } }

    assert_redirected_to post_url(@post)
    assert_equal "An updated title", @post.reload.title
    follow_redirect!
    assert_match "Post was saved", response.body
  end

  test "an update with an invalid title is rejected" do
    sign_in @author
    original_title = @post.title

    patch post_path(@post), params: { post: { title: "no" } }

    assert_match "too short", response.body
    assert_equal original_title, @post.reload.title
  end

  test "a user cannot update someone else's post" do
    sign_in @other
    original_title = @post.title

    assert_raises(ActiveRecord::RecordNotFound) do
      patch post_path(@post), params: { post: { title: "A hijacked title" } }
    end

    assert_equal original_title, @post.reload.title
  end

  # --- Destroy --------------------------------------------------------------

  test "the author can destroy their post" do
    sign_in @author

    assert_difference "Post.count", -1 do
      delete post_path(@post)
    end

    assert_redirected_to posts_url
    assert_not Post.exists?(@post.id)
  end

  test "a user cannot destroy someone else's post" do
    sign_in @other

    assert_raises(ActiveRecord::RecordNotFound) do
      delete post_path(@post)
    end

    assert Post.exists?(@post.id)
  end
end
