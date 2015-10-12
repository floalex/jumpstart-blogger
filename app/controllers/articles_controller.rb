class ArticlesController < ApplicationController
  before_action :require_login, except: [:index, :show]
  
  def index
    @articles, @tag = Article.search_by_tag_name(params[:tag])
    @pages = Page.all
  end
  
  def show
    @article = Article.find(params[:id])
    @comment = Comment.new
    @comment.article_id = @article.id
    @view_count = @article.view_count
  end
  
  def new
    @article = Article.new
  end
  
  def edit
    @article = Article.find(params[:id])
  end
  
  def create
    @article = Article.new(article_params)
    @article.save
    
    redirect_to article_path(@article)
  end
  
  def update
    @article = Article.find(params[:id])
    @article.update(article_params)
    
    flash.notice = "Article '#{@article.title}' Updated!"

    redirect_to article_path(@article)
  end
  
  def destroy
    @article = Article.find(params[:id])
    @article.destroy
    
    redirect_to articles_path
  end
  
  private
  def article_params
    params.require(:article).permit(:title, :body, :tag_list, :image)
  end
  
  def require_login
      redirect_to login_path unless current_user 
    end
end
