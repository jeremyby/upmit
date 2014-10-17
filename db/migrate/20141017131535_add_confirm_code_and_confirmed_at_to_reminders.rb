class AddConfirmCodeAndConfirmedAtToReminders < ActiveRecord::Migration
  def change
    add_column :reminders, :verification_code, :string
    add_column :reminders, :verified_at, :datetime
    add_column :reminders, :remind_at, :float, default: 8.0
  end
end
