class UserMailer < ActionMailer::Base
  helper ApplicationHelper

  default from: "grants@fireflyartscollective.org"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.account_activation.subject
  #
  def account_activation(type, user)
    @user = user
    @type = type

    mail to: @user.email, subject: "Firefly Art Grant Account Activation"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject
  #
  def password_reset(type, user)
    @user = user
    @type = type

    mail to: @user.email, subject: "Firefly Art Grant Password Reset"
  end

  def voter_verified(user, year)
    @user = user
    @year = year

    mail to: @user.email, subject: "Firefly Art Grant Voter Account Verified"
  end

  def grant_funded(submission, artist, grant, year)
    @submission = submission
    @artist = artist
    @grant = grant
    @year = year

    f = "#{Rails.root}/config/template_values.yml"
    @values = YAML.load(File.open(f, "rb").read)[@grant.name]
    if !@values
      raise "ERROR loading email template_values for #{@grant.name}"
    end

    mail to: @artist.email, cc: get_cc(), subject: "#{@year} Firefly #{@grant.name} Grant Decision: #{@submission.name}"
  end

  def grant_not_funded(submission, artist, grant, year)
    @submission = submission
    @artist = artist
    @grant = grant
    @year = year

    mail to: @artist.email, cc: get_cc(), subject: "#{@year} Firefly #{@grant.name} Grant Decision: #{@submission.name}"
  end

  def notify_questions(submission, artist, grant, year)
    @submission = submission
    @artist = artist
    @grant = grant
    @year = year

    # XXX: Hard coded four day deadline is good enough, right?
    d = DateTime.current.next_day(4)
    @due_date = "#{Date::DAYNAMES[d.wday]}, #{d.strftime("%B %-d, %Y")}"

    mail to: @artist.email, cc: get_cc(), subject: "#{@year} Firefly #{@grant.name} Grants: Questions regarding #{@submission.name}"
  end

  private
  def get_cc()
    if Rails.env.production?
      return "grants@fireflyartscollective.org"
    end
    return ""
  end
end
