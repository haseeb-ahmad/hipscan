class User < ActiveRecord::Base
  PROFILE_URL = 'url'
  PROFILE_TEXT = 'custom_text'
  PROFILE_IMAGE = 'custom_image'
  PROFILE_PROFILE = 'profile'
  PROFILE_PAGE = 'custom_page'
  PROFILE_VIDEO = 'video'

  URL = URI::regexp(%w(http https))
  URL_SAFE = /^[a-zA-Z0-9_]*$/
  EMAIL = /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i


  # Include default devise modules. Others available are:
  # :token_authenticatable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :omniauthable
  #:confirmable, 

  has_many :scans, :order => :created_at, :dependent => :destroy
  has_many :clicks, :dependent => :destroy
  has_many :qrs, :dependent => :destroy, :conditions => { :profile_option => 'url' }
  has_many :user_data_items, :dependent => :destroy
  has_one :template, :class_name => "Qr", :foreign_key => "user_id", :conditions => {:profile_option => 'template' }
  
  belongs_to :account
  
  delegate :subscription, :to => :account

  validates_presence_of :username
  validates_format_of :username, :with => URL_SAFE, :message => 'Please use only numbers, letters and underscore for your username'
  validates_length_of :username, :minimum => 3, :maximum => 20, :message => 'must be between 3 and 20 characters'
  validates_length_of :status, :maximum => 200
  validates_uniqueness_of :username
  validates_exclusion_of :username, :in => %w( admin superuser www welcome home about contact terms privacy ), :message => "is not allowed as a username"
  validates_format_of :url, :with => URL, :if => :profile_url?, :message => 'does not appear to be a valid url'
  validates_format_of :video_url, :with => URL, :allow_blank => true, :message => 'does not appear to be a valid url'
  validates_format_of :email_address, :with => EMAIL, :allow_blank => true, :message => 'does not appear to be valid', :if => :profile_profile?
  validates_format_of :facebook_url, :with => URL_SAFE, :allow_blank => true, :message => 'enter your Facebook vanity name'
  validates_format_of :twitter_username, :with => URL_SAFE, :allow_blank => true, :message => 'does not appear to be a valid Twitter username', :if => :profile_profile?
  validates_format_of [:linked_in_profile_url, :website_url, :website_url2, :website_url3, :website_url4, :website_url5], :allow_blank => true, :with => URL, :message => 'does not appear to be valid', :if => :profile_profile?
  validates_format_of :spda_username, :with => URL_SAFE, :allow_blank => true, :message => 'is invalid, use only numbers, letters and underscore', :if => :profile_profile?
  validates_length_of :custom_text, :minimum => 1, :if => :profile_text?
  validates_attachment_presence :image, :if => :profile_image?
  validates_format_of :sms_phone_number, :allow_blank => true, :with => /([0-9]{10})/, :message => 'Must be 10 digits with no spaces'

  def validate
    if profile_video? && video_url.blank? && video_embed.blank?
      errors.add :base, 'Please enter a video url or embed code'
    end

    if profile_video? && video_url.present? && video_embed.present?
      errors.add :base, 'Please choose a video url or embed code, not both'
    end
  end
  
  before_save :check_qr
  after_create :send_welcome_email
  after_create :add_to_batchbook
  before_save :update_batchbook

  has_attached_file :photo, :styles => { :medium => "960x", :thumb => "100x" }
  has_attached_file :image, :styles => { :medium => "960x", :thumb => "100x" }
  has_attached_file :qr,
                    :processors => [:change_color],
                    :styles => {
                        :thumb => {:resize => '60x60', :color => lambda{|a| a.instance.color}},
                        :print => {:resize => '2000x2000', :color => lambda{|a| a.instance.color}},
                        :poster => {:resize => '4000x4000', :color => lambda{|a| a.instance.color}},
                        :medium => {:resize => '400x400', :color => lambda{|a| a.instance.color}}
                        }


  COLORS = ['#000000', '#BF0404', '#272433', '#025928', '#43009A']

#orange: EF5411
#red: BF0404
#dark blue 272433
#green: 025928
#purple: 43009A

  # Setup accessible (or protected) attributes for your model
  attr_accessible :username, :email, :password, :password_confirmation, :remember_me,
                  :profile_option, :url, :image, :custom_text, :display_name, :email_address, :phone_number, :custom_page,
                  :photo, :facebook_url, :twitter_username, :foursquare_username, :status, :spda_username, :linked_in_profile_url,
                  :website_name, :website_url, :website_name2, :website_url2, :website_name3, :website_url3,
                  :website_name4, :website_url4, :website_name5, :website_url5,
                  :sms_phone_number, :sms_carrier, :google_profile_id, :video_url, :video_embed

  def plan_name
    self.subscription.subscription_plan.name
  end

  def send_welcome_email
    begin
      unless self.welcome_email_sent
        if self.valid?
          Notifier.welcome_email(self).deliver
          self.update_attribute(:welcome_email_sent, true)
        end
      end
    rescue
      Rails.logger.debug self.email
      Rails.logger.debug $!
    end
  end
  
  def subscription_plan
    subscription.subscription_plan.name
  end

  def add_to_batchbook
    if Rails.env == 'production'
      Rails.logger.debug "Calling batchbook API for #{self.username}"
      begin
        person = BatchBook::Person.new(:first_name => self.username, :last_name => self.username, :company => 'Hipscan Users', :notes => "Created via batchbook API")
        r = person.save
        person.add_location(:label => 'work', :email => self.email)
        person.add_tag('NoProfile')
        person
      rescue
        Rails.logger.debug "Batchbook API error:"
        Rails.logger.debug $!
      end
    end
  end

  def update_batchbook
    if Rails.env == 'production'
      if self.profile_option.present? && self.profile_option_was.blank?
        begin
          person =  BatchBook::Person.find(:first, :params => {:email => self.email})
          person.remove_tag('NoProfile')
          Rails.logger.debug "Batchbook API removed NoProfile for #{self.username}"
        rescue
          Rails.logger.debug "Batchbook API error:"
          Rails.logger.debug $!
        end
      end
    end
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    login = conditions.delete(:username)
    where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
  end

  # "name"=>"Qollage Wall",
  # "location"=>{"name"=>"San Francisco, California", "id"=>"114952118516947"},
  # "timezone"=>-7,
  # "gender"=>"male",
  # "id"=>"1267856439",
  # "last_name"=>"Wall",
  # "updated_time"=>"2011-03-30T05:23:51+0000",
  # "verified"=>true,
  # "locale"=>"en_US",
  # "hometown"=>{"name"=>"Santiago, Chile", "id"=>"112371848779363"},
  # "link"=>"http://www.facebook.com/profile.php?id=1267856439",
  # "email"=>"qollage@qollage.com", "
  # "first_name"=>"Qollage"}
  #
  def self.find_for_facebook_oauth(access_token, signed_in_resource=nil)
    data = access_token['extra']['user_hash']
    if user = signed_in_resource || User.find_by_facebook_id(data["id"]) || User.find_by_email(data["email"])
      user.update_attribute(:facebook_id, data["id"]) unless user.facebook_id == access_token["uid"]
      user
    else # Create an user with a stub password.
#      u = User.create!(:email => data["email"], :password => Devise.friendly_token[0,20], :first_name => data["first_name"], :last_name => data["last_name"])
#      u.update_attribute(:fb_id, data["id"])
#      u.confirm!
      u = User.new(:email => data["email"], :password => Devise.friendly_token[0,20])
      u.facebook_id = access_token["uid"]
      u.save(false)
      u
    end
  end

  # {"user_info"=>{"name"=>"John Castellucci", "last_name"=>"Castellucci", "email"=>"john.castellucci@gmail.com", "first_name"=>"John"}, "uid"=>"https://www.google.com/accounts/o8/id?id=AItOawkob13osoN3ujzqLmTrBhhzUqsLy_dTaP8", "provider"=>"google"}

  def self.find_for_google_oauth(access_token, signed_in_resource=nil)
    data = access_token['user_info']
    if user = signed_in_resource || User.find_by_google_id(access_token["uid"]) || User.find_by_email(data["email"])
      user.update_attribute(:google_id, access_token["uid"]) unless user.google_id == access_token["uid"]
      user
    else # Create an user with a stub password.
      u = User.new(:email => data["email"], :password => Devise.friendly_token[0,20])
      u.google_id = access_token["uid"]
      u.save(false)
      u
    end
  end

  def user_valid?
    !username.blank? && !email.blank?
  end

  #{"user_info"=>{"name"=>"Qollage Wall", "urls"=>{}, "nickname"=>nil, "phone"=>nil, "last_name"=>"Wall", "image"=>"https://playfoursquare.s3.amazonaws.com/userpix_thumbs/KFHJKX3QZXN3VYDS.jpg", "email"=>"qollage@webjaw.com", "first_name"=>"Qollage"},
  # "uid"=>"9475414",
  # "credentials"=>{"token"=>"MP4R0ITBSKIWNK0A42Y2GD0MF5BUOBQIHG5LAXMRFSOEKVQJ"},
  # "extra"=>{"user_hash"=>{"photo"=>"https://playfoursquare.s3.amazonaws.com/userpix_thumbs/KFHJKX3QZXN3VYDS.jpg", "friends"=>{"groups"=>[{"items"=>[], "name"=>"other friends", "count"=>0, "type"=>"others"}], "count"=>0}, "pings"=>false, "homeCity"=>"San Francisco, CA", "lastName"=>"Wall", "todos"=>{"count"=>0}, "scores"=>{"goal"=>50, "checkinsCount"=>0, "max"=>0, "recent"=>0}, "tips"=>{"count"=>0}, "contact"=>{"facebook"=>"1267856439", "email"=>"qollage@webjaw.com"}, "relationship"=>"self", "gender"=>"male", "id"=>"9475414", "requests"=>{"count"=>0}, "type"=>"user", "badges"=>{"count"=>0}, "firstName"=>"Qollage", "checkins"=>{"count"=>0}, "mayorships"=>{"items"=>[], "count"=>0}, "following"=>{"count"=>0}}}, "provider"=>"foursquare"}

#  def self.find_for_foursquare_oauth(access_token, signed_in_resource=nil)
#    data = access_token['user_info']
#    if user = signed_in_resource || User.find_by_foursquare_id(access_token["uid"]) || User.find_by_email(data["email"])
#      user.update_attribute(:foursquare_id, access_token["uid"]) unless user.foursquare_id == access_token["uid"]
#      user
#    else # Create an user with a stub password.
#      u = User.new(:email => data["email"], :password => Devise.friendly_token[0,20])
#      u.foursquare_id = access_token["uid"]
#      u.save(false)
#      u
#    end
#  end

  # "user_info"=>{
  #      "name"=>"John Castellucci",
  #      "location"=>nil,
  #      "urls"=>{"Website"=>nil, "Twitter"=>"http://twitter.com/johncastellucci"},
  #      "nickname"=>"johncastellucci",
  #      "description"=>nil,
  #      "image"=>"http://a2.twimg.com/profile_images/129271760/John_Samurai_64x64_normal.jpg"
  #     },
  #     "uid"=>"25580454",
  #     "credentials"=>{
  #       "token"=>"25580454-MjcCme1lSXoNDJeTVFVgQ9qRV2THpmVz1h76xzHzl",
  #       "secret"=>"YoSfubiP6MQEQk9s9Pv7pKJ9tlRkB3vf4kABOX7zK0"
  #     },
  #     "extra"=>{
  #       "user_hash"=>{
  #         "name"=>"John Castellucci",
  #         "profile_background_tile"=>false,
  #         "profile_sidebar_fill_color"=>"DDEEF6",
  #         "profile_sidebar_border_color"=>"C0DEED",
  #         "profile_image_url"=>"http://a2.twimg.com/profile_images/129271760/John_Samurai_64x64_normal.jpg",
  #         "created_at"=>"Fri Mar 20 21:31:54 +0000 2009",
  #         "location"=>nil, "profile_link_color"=>"0084B4",
  #         "is_translator"=>false,
  #         "id_str"=>"25580454",
  #         "follow_request_sent"=>false,
  #         "url"=>nil, "contributors_enabled"=>false,
  #         "default_profile"=>true,
  #         "favourites_count"=>0,
  #         "states"=>{
  #           "pending_email"=>false,
  #           "bouncing_email"=>false,
  #           "detached_email"=>false,
  #           "suspended"=>false,
  #           "needs_employee_email_update"=>false
  #          },
  #          "utc_offset"=>nil,
  #          "id"=>25580454,
  #          "listed_count"=>0,
  #          "profile_use_background_image"=>true,
  #          "protected"=>false,
  #          "followers_count"=>6,
  #          "profile_text_color"=>"333333",
  #          "lang"=>"en", "notifications"=>false,
  #          "verified"=>false,
  #          "time_zone"=>nil,
  #          "geo_enabled"=>false,
  #          "profile_background_color"=>"C0DEED",
  #          "description"=>nil,
  #          "friends_count"=>5,
  #          "statuses_count"=>12,
  #          "profile_background_image_url"=>"http://a3.twimg.com/a/1301438647/images/themes/theme1/bg.png",
  #          "default_profile_image"=>false,
  #          "status"=>{
  #            "coordinates"=>nil,
  #            "created_at"=>"Tue Feb 16 16:38:48 +0000 2010",
  #            "favorited"=>false,
  #            "truncated"=>false,
  #            "id_str"=>"9191773568",
  #            "in_reply_to_user_id_str"=>nil,
  #            "entities"=>{
  #              "urls"=>[],
  #              "hashtags"=>[],
  #              "user_mentions"=>[]
  #            },
  #            "contributors"=>nil,
  #            "text"=>"testing from tweetbeat",
  #            "id"=>9191773568,
  #            "retweet_count"=>0,
  #            "in_reply_to_status_id_str"=>nil,
  #            "geo"=>nil,
  #            "retweeted"=>false,
  #            "in_reply_to_user_id"=>nil,
  #            "in_reply_to_screen_name"=>nil,
  #            "source"=>"<a href=\"http://tweetbeat.net\" rel=\"nofollow\">TweetBeat</a>", "place"=>nil, "in_reply_to_status_id"=>nil}, "screen_name"=>"johncastellucci", "following"=>false, "show_all_inline_media"=>false}, "access_token"=>#<OAuth::AccessToken:0x7fde4cbfe578 @params={:oauth_token=>"25580454-MjcCme1lSXoNDJeTVFVgQ9qRV2THpmVz1h76xzHzl", "oauth_token_secret"=>"YoSfubiP6MQEQk9s9Pv7pKJ9tlRkB3vf4kABOX7zK0", :oauth_token_secret=>"YoSfubiP6MQEQk9s9Pv7pKJ9tlRkB3vf4kABOX7zK0", :user_id=>"25580454", "user_id"=>"25580454", :screen_name=>"johncastellucci", "oauth_token"=>"25580454-MjcCme1lSXoNDJeTVFVgQ9qRV2THpmVz1h76xzHzl", "screen_name"=>"johncastellucci"},
  # @consumer=#<OAuth::Consumer:0x7fde4cc26898 @secret="vdg0oemaA3zeMLzO2ciCLSSgAWt8O3QfTMaO7qnMuQ", @key="JTnG1gK502gmt8rZUchtjw", @uri=#<URI::HTTPS:0x7fde4cbfdc68 URL:https://api.twitter.com>, @http_method=:post, @options={:signature_method=>"HMAC-SHA1", :site=>"https://api.twitter.com", :proxy=>nil, :request_token_path=>"/oauth/request_token", :authorize_path=>"/oauth/authenticate", :scheme=>:header, :http_method=>:post, :oauth_version=>"1.0", :access_token_path=>"/oauth/access_token"}, @http=#<Net::HTTP api.twitter.com:443 open=false>>, @secret="YoSfubiP6MQEQk9s9Pv7pKJ9tlRkB3vf4kABOX7zK0", @response=#<Net::HTTPOK 200 OK readbody=true>, @token="25580454-MjcCme1lSXoNDJeTVFVgQ9qRV2THpmVz1h76xzHzl">}, "provider"=>"twitter"}  #
  def self.find_for_twitter_oauth(access_token, signed_in_resource=nil)
    data = access_token['extra']['user_hash']
    if user = signed_in_resource || User.find_by_twitter_id(access_token["uid"])
      user.update_attribute(:twitter_id, access_token["uid"]) unless user.twitter_id == access_token["uid"]
      user.update_attribute(:twitter_username, access_token['user_info']["nickname"]) unless user.twitter_username == access_token['user_info']["nickname"]
      user
    else # Create an user with a stub password.
      u = User.create(:username => access_token['user_info']["nickname"], :password => Devise.friendly_token[0,20])
      u.twitter_id =access_token["uid"]
      u.twitter_username = access_token['user_info']["nickname"]
      u.save(false)
#      u.confirm!
      u
    end
  end

  # "email"=>"johnc@testdev.net"}
  # "uid"=>"https://www.google.com/accounts/o8/id?id=AItOawkHb1PHJ9S7tnGKO-2ZP7IDX1jGs1nBaDU",
  # "provider"=>"open_id"
#  def self.find_for_google_auth(access_token, signed_in_resource=nil)
#    data = access_token['user_info']
#    google_id = access_token['uid'].split('id=').last
#    if user = signed_in_resource || User.find_by_email(data["email"])
#      u.update_attribute(:google_id, google_id) unless u.google_id == google_id
#      user
#    else # Create an user with a stub password.
#      u = User.create(:email => data["email"], :password => Devise.friendly_token[0,20])
#      u.google_id = google_id
#      u.save(false)
#      u.confirm!
#      u
#    end
#  end

  # "user_info"=>{
  #   "name"=>"John Castellucci",
  #   "location"=>"San Francisco Bay Area",
  #   "urls"=>{"LinkedIn"=>"http://www.linkedin.com/pub/john-castellucci/0/795/73b", "Portfolio"=>"http://brandhabit.com"},
  #   "nickname"=>"73b",
  #   "last_name"=>"Castellucci",
  #   "description"=>"Rails Developer / Senior QA Engineer",
  #   "image"=>"http://media.linkedin.com/mpr/mprx/0_in1UQMC8D2QQlpsZSPhkQVCrfa39lxsZTqFXQR1hrIz6mRS47KiBHUba38Td-ZUNGvA5WySinkCZ",
  #   "first_name"=>"John"
  #  },
  #  "uid"=>"wYzlLHIGTo",
  #  "credentials"=>{"token"=>"24d3dd77-c61d-4c4f-90f4-4a9eaa3ba07b", "secret"=>"31bece08-4c93-4ab1-967b-4c401c9f05e1"},
  #  "extra"=>{"access_token"=>#<OAuth::AccessToken:0x7fde4a52e880 @params={:oauth_authorization_expires_in=>"0", "oauth_token_secret"=>"31bece08-4c93-4ab1-967b-4c401c9f05e1",
  #  :oauth_token=>"24d3dd77-c61d-4c4f-90f4-4a9eaa3ba07b", "oauth_expires_in"=>"0", :oauth_token_secret=>"31bece08-4c93-4ab1-967b-4c401c9f05e1", "oauth_token"=>"24d3dd77-c61d-4c4f-90f4-4a9eaa3ba07b", "oauth_authorization_expires_in"=>"0", :oauth_expires_in=>"0"}, @secret="31bece08-4c93-4ab1-967b-4c401c9f05e1", @token="24d3dd77-c61d-4c4f-90f4-4a9eaa3ba07b", @response=#<Net::HTTPOK 200 OK readbody=true>, @consumer=#<OAuth::Consumer:0x7fde4a5490e0 @secret="9N7ZUgfqwjuvgAJas3EYEUio5L0vPJOEen6-juIwapdqbIRuL-G7PsUV0kJsgY_Y", @key="plSLe6qqf5uxkQ01xxyK49eis-NMEGbEXzCmSi9pM9v_saB1zlzdAhFoSHCu-Fw-", @uri=#<URI::HTTPS:0x7fde4a52e060 URL:https://api.linkedin.com>, @http_method=:post, @http=#<Net::HTTP api.linkedin.com:443 open=false>, @options={:oauth_version=>"1.0", :access_token_path=>"/uas/oauth/accessToken", :signature_method=>"HMAC-SHA1", :site=>"https://api.linkedin.com", :proxy=>nil, :request_token_path=>"/uas/oauth/requestToken", :authorize_path=>"/uas/oauth/authenticate", :scheme=>:header, :http_method=>:post}>>},
  #  "provider"=>"linked_in"}
  #
  def self.find_for_linked_in_oauth(access_token, signed_in_resource=nil)
    data = access_token['user_info']
    if user = signed_in_resource || User.find_by_linked_in_id(access_token["uid"])
      user.update_attribute(:linked_in_id, access_token["uid"])
      user
    else # Create an user with a stub password.
      u = User.create(:email => '', :password => Devise.friendly_token[0,20])
      u.linked_in_id =  access_token["uid"]
      u.linked_in_profile_url = data['public_profile_url']
      u.save(false)
#      u.confirm!
      u
    end
  end

  def profile_url?; profile_option == PROFILE_URL; end
  def profile_image?; profile_option == PROFILE_IMAGE; end
  def profile_text?; profile_option == PROFILE_TEXT; end
  def profile_profile?; profile_option == PROFILE_PROFILE; end
  def profile_page?; profile_option == PROFILE_PAGE; end
  def profile_video?; profile_option == PROFILE_VIDEO; end

  def hipscan
    "http://#{APP_CONFIG[:host]}/#{username}"
  end

  def facebook
    "http://www.facebook.com/#{facebook_url}"
  end

  def google_plus
    "http://plus.google.com/#{google_profile_id}"
  end

  def twitter
    "http://twitter.com/#{twitter_username}"
  end

  def socialpda
    "http://socialpda.com/#{spda_username}"
  end

  def update_with_password(params={})
    if params[:password].blank?
      params.delete(:password)
      params.delete(:password_confirmation) if params[:password_confirmation].blank?
    end
    update_attributes(params)
  end


  def check_qr
    generate_qr unless qr.file? || username.blank?
  end

  def generate_qr
    qrencode
    self.qr = File.open(qr_tmp_file)
#    File.delete(qr_tmp_file)
  end

  def premium?
    self.account_type == 'premium1'
  end
  
  def account_plan
    self.subscription.subscription_plan.name
  end

  def at_qr_limit?
    self.qrs.count > 30
  end

  protected

  #  Usage: qrencode [OPTION]... [STRING]
  #  Encode input data in a QR Code and save as a PNG image.
  #
  #    -o FILENAME  write PNG image to FILENAME. If '-' is specified, the result
  #                 will be output to standard output. If -S is given, structured
  #                 symbols are written to FILENAME-01.png, FILENAME-02.png, ...;
  #                 if specified, remove a trailing '.png' from FILENAME.
  #    -s NUMBER    specify the size of dot (pixel). (default=3)
  #    -l {LMQH}    specify error collectin level from L (lowest) to H (highest).
  #                 (default=L)
  #    -v NUMBER    specify the version of the symbol. (default=auto)
  #    -m NUMBER    specify the width of margin. (default=4)
  #    -S           make structured symbols. Version must be specified.
  #    -k           assume that the input text contains kanji (shift-jis).
  #    -c           encode lower-case alphabet characters in 8-bit mode. (default)
  #    -i           ignore case distinctions and use only upper-case characters.
  #    -8           encode entire data in 8-bit mode. -k, -c and -i will be ignored.
  #    [STRING]     input data. If it is not specified, data will be taken from
  #                 standard input.
  #
  def qrencode
    cmd = "#{APP_CONFIG[:path_to_qrencode]} -o #{qr_tmp_file} -lL -s 10 -m 1 '#{hipscan}'"
#    puts cmd
    puts system(cmd)
  end

  def qr_tmp_file
    "#{Rails.root}/tmp/#{username}.png"
  end

  def password_required?
    !persisted? || password.present? || password_confirmation.present?
  end
end


