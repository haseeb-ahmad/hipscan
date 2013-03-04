ActiveAdmin::Dashboards.build do

  # Define your dashboard sections here. Each block will be
  # rendered on the dashboard in the context of the view. So just
  # return the content which you would like to display.
  
  #section "Admin" do
  # div do
  #   "Welcome #{current_user.username}"
  # end
  #end

  section "Stats" do
    @users_count = User.count
    @scans_count = Scan.count
    div do
      render 'stats', { :users_count => @users_count, :scans_count => @scans_count }
    end
  end

 section "Recent Users" do
  ul do
    User.order('created_at DESC').limit(20).collect do |user|
      li raw "#{link_to(user.email, admin_user_path(user))} #{time_ago_in_words(user.last_sign_in_at)} ago"
    end
  end
 end

 section "Recent Scans" do
  ul do
    Scan.order('created_at DESC').limit(20).collect do |scan|
      li raw "#{link_to(scan.user.email, admin_user_path(scan.user))} #{time_ago_in_words(scan.created_at)} ago"
    end
  end
 end

  # == Simple Dashboard Section
  # Here is an example of a simple dashboard section
  #
  #   section "Recent Posts" do
  #     ul do
  #       Post.recent(5).collect do |post|
  #         li link_to(post.title, admin_post_path(post))
  #       end
  #     end
  #   end
  
  # == Render Partial Section
  # The block is rendered within the context of the view, so you can
  # easily render a partial rather than build content in ruby.
  #
  #   section "Recent Posts" do
  #     div do
  #       render 'recent_posts' # => this will render /app/views/admin/dashboard/_recent_posts.html.erb
  #     end
  #   end
  
  # == Section Ordering
  # The dashboard sections are ordered by a given priority from top left to
  # bottom right. The default priority is 10. By giving a section numerically lower
  # priority it will be sorted higher. For example:
  #
  #   section "Recent Posts", :priority => 10
  #   section "Recent User", :priority => 1
  #
  # Will render the "Recent Users" then the "Recent Posts" sections on the dashboard.

end
