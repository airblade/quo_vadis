class QuoVadis::SessionsController < ApplicationController
  skip_filter :authenticate, :except => [:destroy]
  layout :quo_vadis_layout

  # GET sign_in_path
  def new
    render 'sessions/new'
  end

  # POST sign_in_path
  def create
    if blocked?
      flash_if_present :alert, 'quo_vadis.flash.sign_in.blocked', :now
      render 'sessions/new'
    elsif user = QuoVadis.model_class.authenticate(params[:username], params[:password])
      flash_if_present :notice, 'quo_vadis.flash.sign_in.after'
      sign_in user
    else
      QuoVadis.failed_sign_in_hook self
      flash_if_present :alert, 'quo_vadis.flash.sign_in.failed', :now
      render 'sessions/new'
    end
  end

  # GET sign_out_path
  def destroy
    QuoVadis.signed_out_hook send(:"current_#{QuoVadis.model_instance_name}"), self
    self.send :"current_#{QuoVadis.model_instance_name}=", nil
    flash_if_present :notice, 'quo_vadis.flash.sign_out'
    redirect_to QuoVadis.signed_out_url(self)
  end

  # GET forgotten_sign_in_path
  # POST forgotten_sign_in_path
  def forgotten
    if request.get?
      render 'sessions/forgotten'
    elsif request.post?
      if params[:username].present? &&
          (user = QuoVadis.model_class.where(:username => params[:username]).first)
        if user.email.present?
          user.generate_token
          QuoVadis::Notifier.change_password(user).deliver
          flash_if_present :notice, 'quo_vadis.flash.forgotten.sent_email'
          redirect_to :root
        else
          flash_if_present :alert, 'quo_vadis.flash.forgotten.no_email', :now
          render 'sessions/forgotten'
        end
      else
        flash_if_present :alert, 'quo_vadis.flash.forgotten.unknown', :now
        render 'sessions/forgotten'
      end
    end
  end

  # GET change_password_path /sign-in/change-password/:token
  def edit
    if QuoVadis.model_class.valid_token(params[:token]).first
      render 'sessions/edit'
    else
      invalid_token
    end
  end

  # PUT change_password_path /sign-in/change-password/:token
  def update
    if (user = QuoVadis.model_class.valid_token(params[:token]).first)
      if params[:password].present?
        user.password = params[:password]
        if user.save
          user.clear_token
          flash_if_present :notice, 'quo_vadis.flash.forgotten.password_changed'
          sign_in user
        else
          render 'sessions/edit'
        end
      else
        render 'sessions/edit'
      end
    else
      invalid_token
    end
  end

  private

  def invalid_token # :nodoc:
    flash_if_present :alert, 'quo_vadis.flash.forgotten.invalid_token'
    redirect_to forgotten_sign_in_url
  end

  def quo_vadis_layout # :nodoc:
    QuoVadis.layout
  end

  def flash_if_present(key, i18n_key, now = false)
    if now
      flash.now[key] = t(i18n_key) if t(i18n_key).present?
    else
      flash[key] = t(i18n_key) if t(i18n_key).present?
    end
  end

end
