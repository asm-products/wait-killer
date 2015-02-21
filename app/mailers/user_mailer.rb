class UserMailer < ApplicationController
  
  def send_welcome_email(account)
    
	# Create email body
	email_body = "Welcome to #{Rails.application.config.app_name}!" +
	  '<br/><br/>Site url: <a 	  href="http://' + Rails.application.config.domain_name + '">' + Rails.application.config.app_name + '</a>' +
	  '<br/><br/>User name: ' + account.username +
	  '<br/>Email address: ' + account.email_address +
	  '<br/><br/> We hope this service will save you a lot of time.' +
	  '<br/>Please tell your friends!'
	
	# Send the email
	send_mail account.email_address, 'Welcome to ' + Rails.application.config.app_name, email_body
	
  end
  
  def send_password_reset_email(account)

  	# Create email body
	email_body = 'Hello, ' + account.first_name + '.<br /><br />Looks like you requested a password reset.' +
	  '<br/><br/>Click <a href="http://' + Rails.application.config.domain_name + "/person/reset_password?prt=#{ account.password_reset_token}" + '>here</a> to reset your password.'
	
	# Send the email
	send_mail account.email_address, 'Password Reset', email_body
	
  end

  def send_profile_changed_email(account)

     # Create email body
     email_body = 'Hello, ' + account.first_name + '.<br /><br />Your profile was just updated at ' + Rails.application.config.domain_name + '.'

     # Send the email
     send_mail account.email_address, 'Profile Changed', email_body

  end
  
  def send_feedback(userName, comment)
  
    # Send feedback from user to support
	
	email_body = 'From: ' + userName + '<br/><br/>Comments:<br/>' + comment
	send_mail("support@#{Rails.application.config.domain_name}", Rails.application.config.app_name +  ' Comment', email_body)
	
  end
  
  def send_mail(email_address, subject, email_body)

	html_body = wrap_html(email_body)

   # Send email using Pony gem
   # Documentation: https://github.com/benprew/pony

   if Rails.env == 'production'

      Pony.options = {
          :via => :smtp,
          :via_options => {
              :address        => 'smtp.postmarkapp.com',
              :port           => '25',
              :user_name      => Rails.application.config.postmark_token,
              :password       => Rails.application.config.postmark_token,
              :authentication => :plain, # :plain, :login, :cram_md5, no auth by default
              :domain         => "waitkiller.herokuapp.com" # the HELO domain provided by the client to the server
          }
      }

   else

      # letter_opener creates local files and opens them in the browser to prevent email sending during development
      require "letter_opener"

      Pony.options = {
          :via => LetterOpener::DeliveryMethod,
          :via_options => {:location => File.expand_path('../tmp/letter_opener', __FILE__)}
       }
   end

    Pony.mail({
     :to => email_address,
     :subject => subject,
     :body => email_body,
     :html_body => html_body,
      :from => 'support@' +  Rails.application.config.domain_name
     })

  end
  
  def wrap_html(msg)
  # Wrap email message in basic html
  
    return '<div>' + msg + '</div>'
  
  end
  
end
