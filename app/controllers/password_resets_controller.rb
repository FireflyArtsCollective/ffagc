require 'uri'

class PasswordResetsController < ApplicationController
  before_action :get_user, only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]

  def index
    # Without a type specified we don't know what to do...
  end

  def new
    @type = params[:type]
    if @type == "artists"
      @type_name = "Artist"
    elsif @type == "voters"
      @type_name = "Voter"
    elsif @type == "admins"
      @type_name = "Admin"
    else
      redirect_to :action => "index"
    end
  end

  def create
    @type = params[:password_reset][:type]
    email = URI.decode_www_form_component(params[:password_reset][:email]).downcase
    if @type == "artists"
      @user = Artist.find_by(email: email)
    elsif @type == "voters"
      @user = Voter.find_by(email: email)
    elsif @type == "admins"
      @user = Admin.find_by(email: email)
    end
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash.now[:info] = "Email sent with password reset instructions"
      render "sent"
    else
      flash.now[:danger] = "Email address not found"
      render "failure"
    end
  end

  def edit
    @type = params[:type]
  end

  def update
    # XXX: Fix ugly conditionals based on @type
    if @type == "artists"
      p = params[:artist]
      t = :artist
    elsif @type == "voters"
      p = params[:voter]
      t = :voter
    elsif @type == "admins"
      p = params[:admin]
      t = :admin
    end

    if p[:password].empty?
      flash.now[:danger] = "Password can't be empty"
      render 'edit', :type => @type, :email => params[:email]
    elsif @user.update(user_params(t))
      # Clear out the reset digest so it can't be used again.
      @user.update_attribute(:reset_digest, "")
      render "success"
    else
      flash.now[:danger] = "Password mismatch or unknown error"
      render "edit", :type => @type, :email => params[:email]
    end
  end

  private

  def user_params(type)
    params.require(type).permit(:password, :password_confirmation)
  end

  def get_user
    @type = params[:type]

    email = URI.decode_www_form_component(params[:email]).downcase
    if @type == "artists"
      @user = Artist.find_by(email: email)
    elsif @type == "voters"
      @user = Voter.find_by(email: email)
    elsif @type == "admins"
      @user = Admin.find_by(email: email)
    else
      logger.error "Did not have a type, couldn't get user!"
    end
  end

  # Confirms a valid user.
  # TODO: check that this makes sense
  def valid_user
    if !@user || !@user.activated?
      flash.now[:danger] = "Invalid or unactivated user"
      render 'failure'
      return
    end
    begin
      if !BCrypt::Password.new(@user.reset_digest).is_password?(params[:id])
        flash.now[:danger] = "Invalid or already-used reset id."
        render 'failure'
      end
    rescue
      flash.now[:danger] = "Invalid or already-used reset id."
      render 'failure'
    end
  end

  # Checks expiration of reset token.
  def check_expiration
    if @user.password_reset_expired?
      flash.now[:danger] = "Password reset has expired."
      redirect_to new_password_reset_url
    end
  end
end
