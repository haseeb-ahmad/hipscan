class AddTypeToTemplate < ActiveRecord::Migration
  def self.up
    add_column :templates, :template_type, :string
  end

  def self.down
    remove_column :templates, :template_type
  end
end
