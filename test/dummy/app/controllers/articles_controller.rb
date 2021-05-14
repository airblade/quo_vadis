class ArticlesController < ApplicationController
  before_action :require_authentication, except: :index
  before_action :require_two_factor_authentication, only: :very_secret

  def index
  end

  def secret
  end

  def also_secret
  end

  def very_secret
  end

end
