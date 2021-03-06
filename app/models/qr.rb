class Qr < ActiveRecord::Base
  belongs_to :user
  has_many :scans
  has_many :user_data_items
  has_many :template_items
  has_many :links
  has_one :finish, :class_name => "Qr", :foreign_key => "qr_id"
  belongs_to :parent_qr, :class_name => "Qr", :foreign_key => "parent_qr_id"

  scope :multi_url, where(:profile_option => 'multi_url')

  has_attached_file :logo, :styles => { :medium => "400x", :thumb => "100x" }
  has_attached_file :image, :styles => { :medium => "960x", :thumb => "100x" }
  has_attached_file :qr,
                    :processors => [:change_color],
                    :styles => {
                        :thumb => {:resize => '60x60', :color => lambda{|a| a.instance.color}},
                        :email => {:resize => '100x100', :color => lambda{|a| a.instance.color}},
                        :print => {:resize => '2000x2000', :color => lambda{|a| a.instance.color}},
                        :poster => {:resize => '4000x4000', :color => lambda{|a| a.instance.color}},
                        :medium => {:resize => '400x400', :color => lambda{|a| a.instance.color}}
                        }

  validates_presence_of :profile_option, :allow_blank => false
  validates_presence_of :url, :allow_blank => false, :if => :profile_url?
  validates_presence_of :custom_text, :allow_blank => false, :if => :custom_text?
  validates_attachment_presence :image, :if => :custom_image?
  validates_format_of :url, :with => User::URL, :if => :profile_url?, :message => 'does not appear to be a valid url'
  validates_format_of :video_url, :with => User::URL, :allow_blank => true, :message => 'does not appear to be a valid url'

  def validate
    if video? && video_url.blank? && video_embed.blank?
      errors.add :base, 'Please enter a video url or embed code'
    end

    if video? && video_url.present? && video_embed.present?
      errors.add :base, 'Please choose a video url or embed code, not both'
    end
  end

  before_save :make_code, :on => :create
  before_save :check_qr
# before_create :check_template 

  def make_code
    self.code ||= Digest::SHA1.hexdigest((Time.now.to_i + rand(99999)).to_s + "qr" )[0,20]
  end

  def profile_url?; self.profile_option == 'url'; end
  def custom_text?; self.profile_option == 'custom_text'; end
  def custom_image?; self.profile_option == 'custom_image'; end
  def video?; self.profile_option == 'video'; end


  def check_qr
    generate_qr unless qr.file? || code.blank?
  end

  def finish_page
    if self.qr_id.present?
      Qr.find self.qr_id
    end
  end

  def generate_qr
    qrencode
    self.qr = File.open(qr_tmp_file)
  end

  def iphone_link
    device_link 'iphone'
  end

  def android_link
    device_link 'android'
  end

  def blackberry_link
    device_link 'blackberry'
  end

  def device_link device
    unless link = self.links.find_by_device(device)
      link = Link.new
      link.qr_id = self.id
      link.device = device
      link.save
    end
    link
  end

  protected

  def qrencode
    cmd = "#{APP_CONFIG[:path_to_qrencode]} -o #{qr_tmp_file} -lL -s 10 -m 1 'http://#{APP_CONFIG[:host]}/#{code}'"
    puts system(cmd)
  end

  def qr_tmp_file
    "#{Rails.root}/tmp/#{code}.png"
  end

  def check_template
    if self.template == 'conference'
      finish_qr = Qr.new 
      finish_qr.profile_option = 'url'
      finish_qr.tagline = "Shop with us.  Connect with us.  Go mobile!"
      finish_qr.save(:validate => false)
      self.finish = finish_qr
    end
  end
end
