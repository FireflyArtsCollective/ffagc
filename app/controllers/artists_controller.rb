class ArtistsController < ApplicationController
  load_and_authorize_resource

  def show
  end

  def new
    @artist.artist_survey ||= @artist.build_artist_survey
  end

  def create
    if Artist.exists?(email: artist_params[:email].downcase)
      flash[:warning] = "The email address #{artist_params[:email.downcase]} already exists in our system"
      return
    end

    @artist = Artist.new(artist_params)
    @artist.email = @artist.email.downcase

    if @artist.save
      # Send email!
      begin
        UserMailer.account_activation('artists', @artist).deliver_now
        logger.info "email: artist account activation sent to #{@artist.email}"

        render 'create_success'
        return
      rescue
        flash[:warning] = 'Error sending email confirmation'
      end
    end

    render 'new'
  end

  private

  def artist_params
    params.require(:artist).permit(:name, :password_digest, :password,
        :password_confirmation, :email, :contact_name, :contact_phone,
        :contact_street, :contact_city, :contact_state, :contact_zipcode,
        :contact_country, artist_survey_attributes: artist_survey_attributes)
  end

  def artist_survey_attributes
    [
      :has_attended_firefly, :has_attended_firefly_desc,
      :has_attended_regional, :has_attended_regional_desc,
      :has_attended_bm, :has_attended_bm_desc,
      :can_use_as_example
    ]
  end
end
