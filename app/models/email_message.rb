class EmailMessage < ApplicationRecord
  belongs_to :email_account

  validates :message_id, uniqueness: true, presence: true

  scope :unread, -> { where(read: false) }
  scope :read, -> { where(read: true) }
  scope :with_attachments, -> { where(has_attachments: true) }

  def mark_as_read!
    update(read: true)
  end

  def mark_as_unread!
    update(read: false)
  end
end
