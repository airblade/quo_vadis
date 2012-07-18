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
          user.generate_token!
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
      invalid_token :forgotten
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
      invalid_token :forgotten
    end
  end

  # GET invitation_path /sign-in/invite/:token
  def invite
    if (user = QuoVadis.model_class.valid_token(params[:token]).first)
      render 'sessions/invite'
    else
      invalid_token :activation
    end
  end

  # POST activation_path /sign-in/accept/:token
  def accept
    if (user = QuoVadis.model_class.valid_token(params[:token]).first)
      user.username, user.password = params[:username], params[:password]
      # When we create a user who must activate their account, we give them
      # a random username and password.  However we want to treat them as if
      # they weren't set at all.
      user.password_digest = nil if params[:password].blank?
      if user.save
        user.clear_token
        flash_if_present :notice, 'quo_vadis.flash.activation.accepted'
        sign_in user
      else
        render 'sessions/invite'
      end
    else
      invalid_token :activation
    end
  end

  # Invites a user to set up their sign-in credentials.
  def invite_to_activate(user, data = {})
    return false if user.email.blank?
    user.generate_token!
    QuoVadis::Notifier.invite(user, data).deliver
    true
  end
  hide_action :send_invitation

  private

  def invalid_token(workflow) # :nodoc:
    if workflow == :activation
      flash_if_present :alert, 'quo_vadis.flash.activation.invalid_token'
      redirect_to root_path
    else
      flash_if_present :alert, 'quo_vadis.flash.forgotten.invalid_token'
      redirect_to forgotten_sign_in_url
    end
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
