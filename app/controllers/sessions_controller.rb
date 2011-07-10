class SessionsController < ApplicationController

  #before_filter :force_ssl
  def new
    @title = "Sign in"
  end

  def login
    redirect_to '/auth/salesforce'
  end

  def deny_access
    store_location
    redirect_to signin_path, :notice => "Please sign in to access this page."
  end

  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    clear_return_to
  end
      
  def create

    ENV['sfdc_token'] = request.env['omniauth.auth']['credentials']['token']
    ENV['sfdc_instance_url'] = request.env['omniauth.auth']['credentials']['instance_url']
 
    #render :text => request.env['omniauth.auth'].inspect
    user_id = request.env['omniauth.auth']['extra']['user_hash']['user_id']
    nickname = request.env['omniauth.auth']['extra']['user_hash']['nick_name']
    last_status_body = request.env['omniauth.auth']['extra']['user_hash']['status']['body']
    last_status_created_date = request.env['omniauth.auth']['extra']['user_hash']['status']['created_date']
    email = request.env['omniauth.auth']['extra']['user_hash']['email']
    name = request.env['omniauth.auth']['extra']['user_hash']['display_name']
    profile = request.env['omniauth.auth']['extra']['user_hash']['urls']['recent']
    thumbnail = request.env['omniauth.auth']['extra']['user_hash']['photos']['thumbnail']
    org_id = request.env['omniauth.auth']['extra']['user_hash']['organization_id']
    picture = request.env['omniauth.auth']['extra']['user_hash']['photos']['picture']
    active = request.env['omniauth.auth']['extra']['user_hash']['active']
    user_type = request.env['omniauth.auth']['extra']['user_hash']['user_type']
    language = request.env['omniauth.auth']['extra']['user_hash']['language']
    utcOffset = request.env['omniauth.auth']['extra']['user_hash']['utcOffset']
    last_modified_date = request.env['omniauth.auth']['extra']['user_hash']['last_modified_date']

    user = User.find_by_user_id(user_id)

    if user.nil?

      user = User.new(:user_id => user_id,
                       :email => email, 
                       :name => name,
                       :nickname => nickname,
                       :thumbnail => thumbnail,
                       :org_id => org_id,
                       :picture => picture,
                       :last_status_body => last_status_body,
                       :last_status_created_date => last_status_created_date,
                       :profile => profile,
                       :active => active,
                       :user_type => user_type,
                       :language => language,
                       :utcOffset => utcOffset,
                       :last_modified_date => last_modified_date
                    ) 
      user.save
      user = User.find_by_user_id(user_id)
    else

      user.picture = picture
      user.thumbnail = thumbnail
      user.last_status_body = last_status_body
      user.last_status_created_date = last_status_created_date
      user.last_modified_date = last_modified_date
      user.save

    end

    sign_in user
    redirect_back_or user 

  end

  def fail
    render :text => request.env['omniauth.auth'].inspect
  end
  
  def destroy
    sign_out
    redirect_to root_path
  end
  
  #private
  #
  #def force_ssl
  #  if !request.ssl?
  #    redirect_to :protocol => 'https'
  #  end
  #end

end
