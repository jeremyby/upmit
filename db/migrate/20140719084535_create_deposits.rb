class CreateDeposits < ActiveRecord::Migration
  def change
    create_table :deposits do |t|
      t.string      :source,    null: false
      t.string      :payer
      t.string      :token,     null: false
      t.references  :goal,      null: false
      t.references  :user,      null: false
      t.integer     :amount_cents,    null: false
      t.integer     :state,     null: false,      default: 0

      t.timestamps
    end
  end
end
