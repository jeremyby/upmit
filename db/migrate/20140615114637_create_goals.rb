class CreateGoals < ActiveRecord::Migration
  def change
    create_table :goals do |t|
      t.string      :title,           null: false
      t.text        :description
      
      t.text        :schedule_yaml,   null: false
      t.references  :user,            null: false,        index: true
      t.string      :timezone,        null: false
      t.integer     :state,           null: false,        default: 0
      
      t.datetime    :start_time,      null: false
      t.string      :slug,            unique: true,       index: true

      t.timestamps
    end
  end
end
