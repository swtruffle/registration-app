# frozen_string_literal: true
# Every time a team captain invites a user to their team, a new user invite is created.
class UserInvite < ActiveRecord::Base
  belongs_to :team
  belongs_to :user

  enum status: [:Pending, :Accepted, :Rejected]

  after_create :link_to_user, :send_email

  before_validation { self.email = email.downcase }

  validate :uniqueness_of_invite, on: :create

  validates :email, :team, presence: true

  validates :email, email: true

  validates :status, inclusion: { in: statuses.keys }

  # Get only invites in the pending status.
  scope :pending, -> { where(status: 'Pending') }

  # Make sure a user cannot be invited to the same team over and over.
  def uniqueness_of_invite
    unless UserInvite.pending.where(team: team, email: email).empty? && team.users.where(email: email).empty?
      errors.add(:email, :uniqueness)
    end
  end

  def accept
    if team.full?
      false
    elsif user.nil? || !user.team.nil? # Check to make sure user isn't already on a team.
      false
    else
      update_attribute(:status, :Accepted)
      team.users << user
    end
  end

  private

  def send_email
    UserMailer.invite_user(self).deliver_now
  end

  def link_to_user
    update_attribute(:user, User.find_by_email(email))
  end
end
