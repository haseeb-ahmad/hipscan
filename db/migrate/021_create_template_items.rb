class CreateTemplateItems < ActiveRecord::Migration
  def self.up
    create_table :template_items do |t|
      t.references :qr
      t.string :template_name, :field_name, :string_value
      t.integer :int_value
      t.float :float_value
      t.boolean :bool_value
      t.date :date_value
      t.time :time_value
      t.timestamp :timestamp_value
      t.text :text_value
      t.binary :data_binary
      t.string :file_file_name, :file_content_type
      t.integer :file_file_size
    end

    add_column :qrs, 'template', :string
  end

  def self.down
    drop_table :template_items
  end
end
