# To test sign-ups with confirmation (activation / verification)
class SignUpsController < ApplicationController

  def new
    @user = User.new
  end


  def create
    @user = User.new user_params
    if @user.save
      login @user
      if QuoVadis.accounts_require_confirmation
        redirect_to secret_articles_path
      else
        redirect_to articles_path
      end
    else
      render :new
    end
  end

  def show
    @user = User.find params[:id]
  end

  def confirmed
    # Here we could send an email.
    redirect_to after_login_path
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

end
