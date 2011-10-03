class UsersController < ActionController::Base

  def new
    @user = User.new
  end

  def create
    @user = User.new params[:user]
    if @user.save
      flash[:notice] = 'You have signed up!'
      sign_in @user  # <-- Quo Vadis sign-in hook
    else
      render 'new'
    end
  end

end
