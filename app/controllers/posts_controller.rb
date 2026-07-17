class PostsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]

  def index
    @posts = Post.all

    q = params.dig(:search, :q)
    if q.present?
      pattern = "%#{Post.sanitize_sql_like(q)}%"
      @posts = @posts.where("title ILIKE :pattern OR html_body ILIKE :pattern", pattern: pattern)
    end
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)
    @post.author = current_user

    if @post.save
      redirect_to post_url(@post), notice: 'Post was created'
    else
      render action: :new
    end
  end

  def show
    @post = Post.find(params[:id])
  end

  def edit
    @post = current_user.posts.find(params[:id])
  end

  def update
    @post = current_user.posts.find(params[:id])

    if @post.update(post_params)
      redirect_to post_url(@post), notice: 'Post was saved'
    else
      render action: :edit
    end
  end

  def destroy
    current_user.posts.find(params[:id]).destroy
    redirect_to posts_url
  end

  private

  def post_params
    params.require(:post).permit(:title, :html_body)
  end
end
