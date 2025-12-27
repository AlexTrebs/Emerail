class EmailAccount < ApplicationRecord
  belongs_to :user
  has_many :email_messages, dependent: :destroy

  # Use Rails encryption for passwords (reversible) instead of has_secure_password (one-way hash)
  encrypts :password

  enum :provider, { imap: 0, gmail_oauth: 1, outlook_oauth: 2 }

  before_validation :strip_whitespace
  validate :test_imap_connection, if: :should_test_connection?

  validates :provider, presence: true
  validates :username, presence: true
  validates :imap_host, presence: true, if: :imap?
  validates :imap_port, presence: true, numericality: { only_integer: true, greater_than: 0 }, if: :imap?
  validates :password, presence: true, if: :imap?

  private

  def strip_whitespace
    self.imap_host = imap_host.strip if imap_host.present?
    self.username = username.strip if username.present?
  end

  def should_test_connection?
    imap? && (new_record? || password_changed? || imap_host_changed?)
  end

  def test_imap_connection
    require 'net/imap'
    require 'openssl'
    require 'timeout'

    begin
      Timeout.timeout(10) do
        ssl_params = if imap_ssl
          {
            ssl: {
              verify_mode: OpenSSL::SSL::VERIFY_PEER,
              cert_store: OpenSSL::X509::Store.new.tap(&:set_default_paths)
            }
          }
        else
          {}
        end

        imap = Net::IMAP.new(imap_host, port: imap_port, **ssl_params)
        imap.login(username, password)
        imap.disconnect
      end
    rescue Timeout::Error
      errors.add(:base, "Connection timed out. Please check your IMAP settings.")
    rescue Net::IMAP::NoResponseError, Net::IMAP::BadResponseError
      errors.add(:base, "Invalid username or password. Please check your credentials.")
    rescue SocketError
      errors.add(:base, "Cannot connect to #{imap_host}. Please check the server address.")
    rescue => e
      errors.add(:base, "Connection failed: #{e.message}")
    end
  end
end
