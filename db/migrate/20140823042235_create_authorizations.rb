class CreateAuthorizations < ActiveRecord::Migration
  def change
    create_table :authorizations do |t|
      t.references :user, index: true
      t.string :provider, null: false
      t.string :uid,      null: false
      t.text :token
      t.text :secret
      t.text :link

      t.timestamps
    end
  end
end
