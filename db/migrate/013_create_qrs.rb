class CreateQrs < ActiveRecord::Migration
  def self.up
    create_table :qrs do |t|
      t.references :user
      t.string :code, :profile_option, :url, :title, :tagline
      t.string :color, :default => 'black'

      t.text :custom_text, :marketing_text
      t.string :logo_file_name, :image_file_name, :logo_content_type, :image_content_type, :qr_file_name, :qr_content_type
      t.integer :logo_file_size, :image_file_size, :qr_file_size
      t.timestamps
    end
  end

  def self.down
    drop_table :qrs
  end
end
