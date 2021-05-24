# To test sign-ups with confirmation (activation / verification)
class SignUpsController < ApplicationController

  around_action :toggle_confirmation

  def new
    @user = User.new
  end


  def create
    @user = User.new user_params
    if @user.save
      if QuoVadis.accounts_require_confirmation
        request_confirmation @user
        redirect_to quo_vadis.confirmations_path
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

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def toggle_confirmation
    QuoVadis.accounts_require_confirmation true
    yield
  ensure
    QuoVadis.accounts_require_confirmation false
  end

end
