class Grant < ActiveRecord::Base
  has_many :grants_voters
  has_many :grant_submissions

  has_many :voters, through: :grants_voters

  validates :name, presence: true
  validates :contract_template, presence: true
  validates :submit_start, presence: true
  validates :submit_end, presence: true
  validates :vote_start, presence: true
  validates :vote_end, presence: true
  validates :meeting_one, presence: true
  validates :meeting_two, presence: true
  # Currently the only place the "hidden" attribute is used is in the voter
  # signup page.  The intent is that some grants may be private and only voted
  # on by the Art Core.  Admins should modify individual voters to add them
  # to hidden grants.

  scope :voting_active, -> (now, deadline, timezone_string) do
    where("vote_start <= datetime(?, ?)", now, timezone_string).where("vote_end >= datetime(?, ?)", deadline, timezone_string)
  end

  scope :submission_active, -> (now, deadline, timezone_string) do
    where("submit_start <= datetime(?, ?)", now, timezone_string).where("submit_end >= datetime(?, ?)", deadline, timezone_string)
  end

  validate :dates_ordering

  validate :funding_levels_syntax

  private

  # Returns all of the grants, minus the hidden ones if the param is true.
  def self.all_maybe_hidden(can_view_hidden)
    if !can_view_hidden
      Grant.where(hidden: false)
    else
      Grant.all
    end
  end

  def dates_ordering
    validate_date_order(submit_start, submit_end, :submit_start, 'must be after submission end date')
    validate_date_order(vote_start, vote_end, :vote_start, 'must be after vote end date')
    validate_date_order(meeting_one, vote_end, :meeting_one, 'must be before vote end date')
    validate_date_order(meeting_two, vote_end, :meeting_two, 'must be before vote end date')
    validate_date_order(meeting_one, meeting_two, :meeting_one, 'must be before second meeting')
  end

  def validate_date_order(first_date, second_date, error_key, error_message)
    return if second_date > first_date
    errors.add(error_key, error_message)
  end

  def funding_levels_syntax
    if funding_levels_csv == nil
      return
    end

    # Valid example: "0, 10-49, 500, 1000-2000"
    errmsg = 'must be comma separated single integers or hyphenated interger ranges'
    tokens = funding_levels_csv.split(',')
    tokens.each do |token|
      limits = token.split("-")
      if limits.length == 1
        begin
          Integer(limits[0])
        rescue ArgumentError
          errors.add(:funding_levels_csv, errmsg)
        end
      elsif limits.length == 2
        begin
          lower = Integer(limits[0])
          upper = Integer(limits[1])
          if lower > upper
            errors.add(:funding_levels_csv, 'upper limit must be greater than lower limit')
          end
        rescue ArgumentError
          errors.add(:funding_levels_csv, errmsg)
        end
      else
        errors.add(:funding_levels_csv, errmsg)
      end
    end
  end
end
