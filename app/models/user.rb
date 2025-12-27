class User < ApplicationRecord
  has_many :email_accounts, dependent: :destroy
  has_many :email_messages, through: :email_accounts

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :timeoutable
end

