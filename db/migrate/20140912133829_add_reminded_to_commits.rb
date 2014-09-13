class AddRemindedToCommits < ActiveRecord::Migration
  def change
    add_column :commits, :reminded, :integer, default: -1
  end
end
