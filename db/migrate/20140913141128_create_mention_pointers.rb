class CreateMentionPointers < ActiveRecord::Migration
  def change
    create_table :mention_pointers do |t|
      t.integer :twitter, limit: 8, default: 1
      t.integer :facebook, limit: 8, default: 722859861120858

      t.timestamps
    end
  end
end
