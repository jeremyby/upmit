class CreateMentionPointers < ActiveRecord::Migration
  def change
    create_table :mention_pointers do |t|
      t.integer :since_id, limit: 8, default: 1

      t.timestamps
    end
  end
end
