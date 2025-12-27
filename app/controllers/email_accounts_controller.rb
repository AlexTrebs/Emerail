class EmailAccountsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_account, only: [:destroy, :sync]

  def index
    @accounts = current_user.email_accounts.order(created_at: :desc)
  end

  def new
    @account = EmailAccount.new
  end

  def create
    @account = current_user.email_accounts.build(account_params)
    if @account.save
      # Trigger initial sync in background
      SyncEmailAccountJob.perform_async(@account.id)
      redirect_to email_accounts_path, notice: "Account added! Syncing emails in background..."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @account.destroy
    redirect_to email_accounts_path, notice: "Account removed successfully"
  end

  def sync
    SyncEmailAccountJob.perform_async(@account.id)
    redirect_to email_accounts_path, notice: "Syncing emails in background..."
  end

  private

  def set_account
    @account = current_user.email_accounts.find(params[:id])
  end

  def account_params
    params.require(:email_account).permit(
      :provider, :imap_host, :imap_port, :imap_ssl,
      :username, :password
    )
  end
end
