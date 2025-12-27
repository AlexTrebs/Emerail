class CreateEmailMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :email_messages do |t|
      t.references :email_account, null: false, foreign_key: true
      t.string :message_id
      t.string :from_address
      t.string :subject
      t.datetime :date
      t.text :body

      t.timestamps
    end
  end
end
