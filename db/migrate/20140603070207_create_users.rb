class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string    :avatar
      
      t.string    :first_name
      t.string    :last_name
      
      t.string    :username
      
      t.string    :slug,        unique: true,       index: true

      t.timestamps
    end
  end
end
