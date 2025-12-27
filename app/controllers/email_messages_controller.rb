class EmailMessagesController < ApplicationController
  before_action :authenticate_user!

  def index
    @messages = current_user.email_messages.includes(:email_account)

    # Apply filters
    if params[:account_id].present?
      @messages = @messages.where(email_account_id: params[:account_id])
    end

    if params[:status] == "unread"
      @messages = @messages.unread
    elsif params[:status] == "read"
      @messages = @messages.read
    end

    if params[:attachments] == "true"
      @messages = @messages.with_attachments
    end

    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @messages = @messages.where(
        "subject ILIKE ? OR from_address ILIKE ? OR body ILIKE ?",
        search_term, search_term, search_term
      )
    end

    # Get counts before pagination (these should reflect ALL messages, not filtered ones)
    @total_count = current_user.email_messages.count
    @unread_count = current_user.email_messages.unread.count

    @messages = @messages.order(date: :desc)
                         .page(params[:page])
                         .per(50)

    # Auto-load older emails when on last page and we have a full page of results
    if @messages.last_page? && @messages.size == 50 && params[:page].to_i > 1
      oldest_email = current_user.email_messages.order(date: :asc).first
      if oldest_email && oldest_email.date > 1.year.ago
        # Sync emails from 30 days before oldest up to oldest
        start_date = oldest_email.date - 30.days
        end_date = oldest_email.date
        # Trigger background sync for older emails (only once per session to avoid duplicates)
        unless session[:loading_older_emails]
          current_user.email_accounts.each do |account|
            SyncOlderEmailsJob.perform_async(account.id, start_date.to_s, end_date.to_s)
          end
          session[:loading_older_emails] = true
          flash.now[:notice] = "Loading older emails in the background..."
        end
      end
    else
      session[:loading_older_emails] = false
    end
  end

  def show
    @message = current_user.email_messages.find(params[:id])
    @message.mark_as_read! unless @message.read?
  end

  def mark_read
    @message = current_user.email_messages.find(params[:id])
    @message.mark_as_read!
    redirect_to email_messages_path, notice: "Message marked as read"
  end

  def mark_unread
    @message = current_user.email_messages.find(params[:id])
    @message.mark_as_unread!
    redirect_to email_messages_path, notice: "Message marked as unread"
  end
end
