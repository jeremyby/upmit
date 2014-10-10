class AddPayerIdAndTransactionIdToDeposit < ActiveRecord::Migration
  def change
    add_column :deposits, :payer_id, :string
    add_column :deposits, :transaction_id, :string
  end
end
