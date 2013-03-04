ActiveAdmin.register User do
  menu :priority => 1
  filter :email
  actions :index, :edit, :update, :show

  controller do
    alias_method :update_ori, :update

    def update
      user = User.find params[:id]
      user.update_attributes params[:user]

      # Rails.logger.debug "XXX"      
      update_ori
    end
  end

  # form do |f|
  #      f.inputs "User Details" do
  #         f.input :email
  #      end
  #   f.buttons
  # end

  index do
    column :username do |user|
      link_to user.username, "/#{user.username}?noscan=1", :target => '_blank'
    end
    column :email
    column :profile_option
    column :account_type
    #column :created_at
    column :last_sign_in_at
    column :sign_in_count
    column :scan_count do |user|
      user.scans.count.to_s
    end
    column  do |user|
      links = link_to I18n.t('active_admin.view'), admin_user_path(user), :class => "member_link view_link"
      links += link_to I18n.t('active_admin.edit'), edit_admin_user_path(user), :class => "member_link edit_link"
      links += link_to 'Impersonate', impersonate_admin_user_path(user), :class => "member_link"
      links += link_to 'Upgrade', premium_admin_user_path(user), :class => "member_link" unless user.premium?
      #links += link_to 'Make Admin', make_admin_admin_user_path(user), :class => "member_link"
      links
    end
  end

  show do
    attributes_table :username, :email, :password, :password_confirmation, :remember_me,
                  :profile_option, :url, :image, :custom_text, :display_name, :email_address, :phone_number, :custom_page,
                  :photo, :facebook_url, :twitter_username, :foursquare_username, :status, :spda_username, :linked_in_profile_url,
                  :website_name, :website_url, :website_name2, :website_url2, :website_name3, :website_url3,
                  :website_name4, :website_url4, :website_name5, :website_url5, :account_admin,
                  :sms_phone_number, :sms_carrier, :google_profile_id, :video_url, :video_embed, :description
  end

  member_action :impersonate do
    sign_in(:user, User.find(params[:id]))
    redirect_to root_path
  end
  
  member_action :make_admin do
    User.find(params[:id]).update_attribute(:admin, true)
    redirect_to admin_users_path, :notice => 'User is now an admin'
  end
  member_action :premium do
    User.find(params[:id]).update_attribute(:account_type, 'premium')
    redirect_to admin_users_path, :notice => 'User is now premium'
  end
end