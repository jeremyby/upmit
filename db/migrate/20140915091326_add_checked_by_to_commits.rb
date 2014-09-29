class AddCheckedByToCommits < ActiveRecord::Migration
  def change
    add_column :commits, :checked_by, :string
  end
end
