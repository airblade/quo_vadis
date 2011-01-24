class ArticlesController < ApplicationController
  before_filter :authenticate, :except => [:index, :show]

  def index
    @articles = Article.all
  end

  def new
    @article = Article.new
  end
end
