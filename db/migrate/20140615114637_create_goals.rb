class CreateGoals < ActiveRecord::Migration
  def change
    create_table :goals do |t|
      t.string      :title,           null: false
      t.text        :description
      t.string      :timezone,        null: false
      t.text        :schedule_yaml
      t.references  :user,            null: false,        index: true
      t.integer     :state,           null: false,        default: 0
      
      t.string      :weekdays
      t.string      :interval,        null: false,        default: 1
      t.string      :interval_unit,   null: false
      t.datetime    :start_time
      t.string      :slug,            index: true

      t.timestamps
    end
  end
end
