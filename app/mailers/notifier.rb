class Notifier < ActionMailer::Base
  layout 'notifier' # use notifier.(html|text).erb as the layout
  default :from => "noreply@hipscan.com"
  default_url_options[:host] = APP_CONFIG[:host]

  helper :application

  def contact_email(from_email, message)
    @from_email = from_email
    @message  = message
    mail(:to => APP_CONFIG[:contact_email], :subject => "Hipscan Contact from #{from}")
  end

  def welcome_email(user)
    @user = user
    @url  = "http://example.com/login"
    mail(:to => user.email, :subject => "Welcome to Hipscan!")
  end

  def getinfo_email(params)
    @params = params
    mail(:to => 'creative@hipscan.com', :subject => "Hipscan Professional Services")
  end

  def services_request_email(params)
    @params = params
    mail(:to => 'marketing@hipscan.com', :subject => "Hipscan Professional Services Info Request")
  end

  def vcard_email(recipient, vcard)
    attachments["contact.vcf"] = { :content=> vcard.to_s, :mime_type => "text/x-vcard", :encoding => "base64" }
    mail(:to => recipient, :subject => 'Your Hipscan vcard has been received!')
  end
end
