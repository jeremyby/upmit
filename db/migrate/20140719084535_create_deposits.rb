class CreateDeposits < ActiveRecord::Migration
  def change
    create_table :deposits do |t|
      t.string      :source,    null: false
      t.string      :payer,     null: false
      t.string      :token,     null: false
      t.references  :goal,      null: false
      t.references  :user,      null: false
      t.integer     :amount,    null: false
      t.integer     :state,     null: false,      default: 1

      t.timestamps
    end
  end
end
