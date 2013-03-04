class AddPageTypeToTemplates < ActiveRecord::Migration
  def self.up
    add_column :template_items, :page_field_name, :string
  end

  def self.down
    remove_column :template_items, :page_field_name
  end
end
