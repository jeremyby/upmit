class CreateReminders < ActiveRecord::Migration
  def change
    create_table :reminders do |t|
      t.text        :type,          null: false
      t.string      :recipient,     null: false
      t.string      :recipient_id,  null: false
      t.integer     :state,         null: false,        default: 1
      t.references  :user,          null: false,        index: true
      
      t.timestamps
    end
  end
end
