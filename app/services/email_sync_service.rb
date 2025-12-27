require "net/imap"
require "mail"
require "openssl"

class EmailSyncService
  BATCH_SIZE = 50
  DEFAULT_SYNC_DAYS = 30

  def initialize(account)
    @account = account
  end

  def sync!(start_date: nil, end_date: nil, limit: nil)
    return unless @account.imap?

    imap = nil
    begin
      # Connect to IMAP with SSL configuration
      ssl_params = {
        ssl: {
          verify_mode: OpenSSL::SSL::VERIFY_PEER,
          cert_store: OpenSSL::X509::Store.new.tap(&:set_default_paths)
        }
      }
      imap = Net::IMAP.new(@account.imap_host, port: @account.imap_port, **ssl_params)
      imap.login(@account.username, @account.password)
      imap.select("INBOX")

      # Get message IDs to sync
      if start_date && end_date
        # Sync specific date range (for loading older emails)
        # Get emails between start_date and end_date
        start_str = start_date.strftime("%d-%b-%Y")
        end_str = end_date.strftime("%d-%b-%Y")
        ids = imap.search(["SINCE", start_str, "BEFORE", end_str])
        # Sort by ID descending to get newest first, then limit
        ids = ids.sort.reverse.first(limit) if limit
      elsif start_date
        # Sync from start_date onwards
        date = start_date.strftime("%d-%b-%Y")
        ids = imap.search(["SINCE", date])
        ids = ids.sort.reverse.first(limit) if limit
      else
        # Normal sync - from last sync or 30 days
        date = (@account.last_synced_at || DEFAULT_SYNC_DAYS.days.ago).strftime("%d-%b-%Y")
        ids = imap.search(["SINCE", date])
        # Sort by ID descending to get newest first
        ids = ids.sort.reverse
      end

      Rails.logger.info "Syncing #{ids.count} messages for account #{@account.id}"

      # Process messages in batches (newest first)
      ids.each_slice(BATCH_SIZE) do |batch|
        batch.each do |id|
          process_message(imap, id)
        rescue StandardError => e
          Rails.logger.error "Failed to process message #{id}: #{e.message}"
        end
      end

      @account.update(last_synced_at: Time.current) unless start_date
      Rails.logger.info "Sync completed for account #{@account.id}"
    rescue StandardError => e
      Rails.logger.error "Sync failed for account #{@account.id}: #{e.message}"
      raise
    ensure
      imap&.disconnect if imap
    end
  end

  private

  def process_message(imap, id)
    msg = imap.fetch(id, "RFC822")[0].attr["RFC822"]
    mail = Mail.read_from_string(msg)

    return if mail.message_id.blank?

    # Find or create, and update if HTML body is missing
    email_msg = EmailMessage.find_or_initialize_by(
      email_account: @account,
      message_id: mail.message_id
    )

    # Always update if new, or if HTML body is missing
    if email_msg.new_record? || email_msg.html_body.blank?
      email_msg.assign_attributes(
        from_address: extract_address(mail.from),
        to_addresses: extract_addresses(mail.to),
        subject: mail.subject || "(No subject)",
        date: mail.date || Time.current,
        body: extract_text_body(mail),
        html_body: extract_html_body(mail),
        has_attachments: mail.attachments.any?
      )
      email_msg.save!
    end
  end

  def extract_address(addresses)
    addresses&.first
  end

  def extract_addresses(addresses)
    addresses || []
  end

  def extract_text_body(mail)
    body = if mail.multipart?
      mail.text_part&.decoded || ""
    else
      decoded = mail.body.decoded
      # Check if body looks like HTML
      if looks_like_html?(decoded)
        ""  # This is HTML, don't use it as text
      elsif mail.content_type&.include?("text/plain") || mail.content_type.nil?
        decoded
      else
        ""
      end
    end
    sanitize_encoding(body)
  rescue StandardError => e
    Rails.logger.error "Failed to extract text body: #{e.message}"
    ""
  end

  def extract_html_body(mail)
    body = if mail.multipart?
      mail.html_part&.decoded || ""
    else
      decoded = mail.body.decoded
      # Check content-type or if body looks like HTML
      if mail.content_type&.include?("text/html") || looks_like_html?(decoded)
        decoded
      else
        ""
      end
    end
    sanitize_encoding(body)
  rescue StandardError => e
    Rails.logger.error "Failed to extract HTML body: #{e.message}"
    ""
  end

  def looks_like_html?(text)
    return false if text.nil? || text.empty?
    # Check if text starts with common HTML markers
    text.strip =~ /\A\s*<!DOCTYPE html/i ||
    text.strip =~ /\A\s*<html/i ||
    text.include?("<html") && text.include?("</html>")
  end

  def sanitize_encoding(text)
    return "" if text.nil?
    # Force UTF-8 encoding and replace invalid characters
    text.encode('UTF-8', invalid: :replace, undef: :replace, replace: '?')
  end
end
