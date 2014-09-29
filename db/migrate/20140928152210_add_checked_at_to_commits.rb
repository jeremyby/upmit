class AddCheckedAtToCommits < ActiveRecord::Migration
  def change
    add_column :commits, :checked_at, :datetime
  end
end
