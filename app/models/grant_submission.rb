class GrantSubmission < ActiveRecord::Base
  belongs_to :grant
  belongs_to :artist

  scope :funded, -> { where('granted_funding_dollars > ?', 0).where(funding_decision: true) }

  has_many :proposals, inverse_of: :grant_submission
  has_many :votes
  has_many :voter_submission_assignments
  has_many :voters, through: :voter_submission_assignments

  delegate :max_funding_dollars, to: :grant

  accepts_nested_attributes_for :proposals

  mount_uploader :proposal, GrantProposalUploader

  validates :name, presence: true, length: { minimum: 4 }
  # Can't require proposal because modification might not change the proposal.
  # validates :proposal, :presence => true

  validates :grant, presence: true

  # Max value depends on the grant
  validates :requested_funding_dollars, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: :max_funding_dollars, only_integer: true }

  # This is supposed to check size before upload but I don't think it does.
  # It does validate after upload, though, so it's not DDOS-proof but it will
  # prevent randos from using the grants server as an ftp site
  validate :proposal_validation, if: :proposal?

  before_save :update_question_and_answer_dates

  def proposal_validation
    return unless proposal.size > 100.megabytes

    logger.warn "rejecting large upload: #{proposal.inspect}"
    errors[:proposal] << 'File must be less than 100MB'
  end

  def funded?
    funding_decision && (granted_funding_dollars || 0) > 0
  end

  def has_questions?
    questions.present?
  end

  def self.granted_funding_dollars_total(query)
    GrantSubmission.where(query).sum(:granted_funding_dollars)
  end

  private

  def update_question_and_answer_dates
    # TODO: is there a nice way to have this be the same as the new updated_at

    if questions_changed?
      self.questions_updated_at = Time.zone.now
    end

    if answers_changed?
      self.answers_updated_at = Time.zone.now
    end
  end
end
