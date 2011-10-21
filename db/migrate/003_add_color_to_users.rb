class AddColorToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :color, :string, :default => 'black'
  end

  def self.down
    remove_column :users, :color
  end
end
