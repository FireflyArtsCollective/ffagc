require 'user_finder'

class AccountActivationsController < ApplicationController
  # this GET request action can edit a user
  def show
    @type = params[:type]
    @email = params[:email]
    @user = UserFinder.find_by_email(@type, @email)

    redirect_if_current_user_activated and return

    if @user&.activation_token_valid?(params[:id])
      @user.activate!

      render 'show'
    end
  rescue ActiveRecord::ActiveRecordError => e
    render 'show'
  end

  # Reset activation token and send activation email
  def create
    @user = current_user
    authorize! :request_activation, @user

    @type = UserFinder.type_from_user(@user)

    begin
      redirect_if_current_user_activated and return

      raise if @user.activated? || @user.nil?

      @user.create_activation_digest
      @user.save!

      UserMailer.account_activation(@type, @user).deliver_now
    rescue
      flash[:info] = 'Error sending email confirmation'
    end

    redirect_to root_path
  end

  private

  def redirect_if_current_user_activated
    if @user&.activated? && @user == current_user
      after_activate
    end
  end

  def after_activate
    flash[:info] = 'Account already activated.'
    redirect_to root_path
  end
end
