class UserFinder
  def self.find_by_email(type, email)
    email = normalize_email(email)

    if type == 'artists'
      Artist.find_by(email: email)
    elsif type == 'voters'
      Voter.find_by(email: email)
    elsif type == 'admins'
      Admin.find_by(email: email)
    end
  end

  def self.find_by_email!(type, email)
    user = find_by_email(type, email)

    raise ActiveRecord::RecordNotFound if user.nil?

    user
  end

  def self.type_from_user(user)
    if user.is_a? Admin
      'admins'
    elsif user.is_a? Artist
      'artists'
    elsif user.is_a? Voter
      'voters'
    end
  end

  private_class_method def self.normalize_email(email)
    URI.decode_www_form_component(email || '').downcase.strip
  end
end
