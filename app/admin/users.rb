ActiveAdmin.register User do
  menu :priority => 1
  filter :email
  actions :index, :edit, :update, :show

  index do
    column :username do |user|
      link_to user.username, "/#{user.username}?noscan=1", :target => '_blank'
    end
    #column :email
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
