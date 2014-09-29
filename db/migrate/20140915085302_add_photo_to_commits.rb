class AddPhotoToCommits < ActiveRecord::Migration
  def change
    add_column :commits, :photo, :string
  end
end
