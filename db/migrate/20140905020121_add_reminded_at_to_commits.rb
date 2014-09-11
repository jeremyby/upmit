class AddRemindedAtToCommits < ActiveRecord::Migration
  def change
    add_column :commits, :reminded_at, :datetime
  end
end
