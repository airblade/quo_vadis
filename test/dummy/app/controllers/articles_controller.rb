class ArticlesController < ApplicationController
  before_filter :authenticate, :except => [:index, :show]

  def index
    @articles = Article.all
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new params[:article]
    if @article.save
      redirect_to :action => 'index'
    else
      render 'new'
    end
  end
end
