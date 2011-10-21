class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.string :account_type
      t.string :description
      t.float :price
      t.timestamps
    end
    
    add_column :users, :account_id, :integer
  end

  def self.down
    remove_column :users, :account_id
    drop_table :accounts
  end
end
