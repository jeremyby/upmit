class CreateCommits < ActiveRecord::Migration
  def change
    create_table :commits do |t|
      t.text        :note
      t.references  :goal,        null: false,    index: true
      t.references  :user,        null: false,    index: true
      t.integer     :state,       null: false,    default: 0
      t.datetime    :starts_at,   null: false

      t.timestamps
    end
  end
end
