class Choogle < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :proposals, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :places, through: :proposals

  validates :slug, presence: true

  validate do |choogle|
    choogle.errors.add(:base, "Please add a title to your poll, so your friends understand what it is") if choogle.title.blank?
    choogle.errors.add(:base, "Please tell your friends when the event will take place") if choogle.happens_at.blank?
    choogle.errors.add(:base, "Please set a deadline for your poll") if choogle.due_at.blank?
  end

  validate :happens_at_cannot_be_in_the_past, :due_at_cannot_be_in_the_past, :due_at_must_be_before_happens_at

  before_validation :generate_slug, on: :create

  def due_at_tz
    # Compatibility for old Choogle or maybe some clients unable to get Timezone
    return due_at if user.timecode == nil
    # Must use the local to UTC method of the gem because the time inputs with the
    # datepicker is considered as the local time for the user but stored in UTC.
    tz = TZInfo::Timezone.get(user.timecode)
    tz.local_to_utc(due_at)
  end

  def generate_slug
    slug = SecureRandom.urlsafe_base64(5)
    while Choogle.find_by(slug: slug)
      slug = SecureRandom.urlsafe_base64(5)
    end
    self.slug = slug
  end

  # slug in the params
  def to_param
    slug
  end

  def happens_at_cannot_be_in_the_past
    if happens_at.present? && happens_at < Time.current
      errors.add(:base, "Sorry, but you can't use Choogle in the past 😊")
    end
  end

  def due_at_cannot_be_in_the_past
    if due_at.present? && self.due_at_tz < Time.current
      errors.add(:base, "The deadline can't be set in the past 😊")
    end
  end

  def due_at_must_be_before_happens_at
    if due_at.present? && happens_at.present? && due_at >= happens_at
      errors.add(:base, "The deadline should be set before the date of your event 😊")
    end
  end

end
