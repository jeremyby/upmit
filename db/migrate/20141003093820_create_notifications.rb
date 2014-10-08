class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.string :notifyable_type, index: true
      t.integer :notifyable_id, index: true
      
      t.integer :user_id, null: false
      t.boolean :read, default: false
      t.string :event

      t.timestamps
    end
  end
end
