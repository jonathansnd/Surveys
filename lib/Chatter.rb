require 'httparty'

class Chatter

  include HTTParty
  #doesn't seem to pick up env variable correctly if I set it here
  #headers 'Authorization' => "OAuth #{ENV['sfdc_token']}"
  format :json
  #debug_output $stderr

  def initialize(current_user)
    @current_user = current_user
    @serviceauth = @current_user.services.find(:first, :conditions => { :provider => 'forcedotcom' })
    @accesstoken = nil
  end

  def set_headers
    payload = 'grant_type=refresh_token' + '&client_id=' + ENV['sfdc_consumer_key']+ '&client_secret=' + ENV['sfdc_consumer_secret'] + '&refresh_token=' + @serviceauth.token_refresh
    result = Chatter.post('https://login.salesforce.com/services/oauth2/token',:body => payload)
    @serviceauth.token = result['access_token']
    @serviceauth.save
    Chatter.headers 'Authorization' => "OAuth #{@serviceauth.token}"
  end

  def root_url
    @root_url = @serviceauth.instance_url+"/services/data/v"+ENV['sfdc_api_version']+"/chatter"
  end

  def get_users_info(id)
    set_headers
    @resp = Chatter.get(root_url+"/users/"+id)
    return @resp
  end

  def get_my_info
    get_users_info("me")
  end
  
  def get_newsfeed(id)
    set_headers
    @resp = Chatter.get(root_url+"/feeds/news/"+id)
    log_response(@resp, "get_newsfeed")
    return @resp
  end
    
  def get_my_newsfeed
    get_newsfeed("me")
  end
  
  def set_my_user_status(post)
    Chatter.post(root_url+"/feeds/news/me/feed-items?text="+CGI::escape(post.body))
  end
  
  def like_feeditem(id)
    Chatter.post(root_url+"/feed-items/"+id+"/likes")
  end
  
  def unlike_feeditem(id)
    delete(root_url+"/feed-items/"+id+"/likes")
  end
  
  def add_comment(comment)
    Chatter.post(root_url+"/feed-items/"+comment.feeditemid+"/comments?text="+CGI::escape(comment.body))
  end
  
  
  #pre rel chatter page results returns the incorrect json response. it should be [feeditems][items]
  #like everything else, but it is just [items] so lets wrap it to make it consistent
  def get_page_of_feed(refpath)
    set_headers
    
     @feed = Hash.new{}
      @feed["feedItems"] = Hash.new{} 
      
       @feed["feedItems"] = Chatter.get(@serviceauth.instance_url+refpath)
       return @feed
  end
  
  def log_response(resp, method_name)
    CHATTER_LOGGER.debug("\n------START "+method_name+"---------\n")
    CHATTER_LOGGER.debug(resp)
    CHATTER_LOGGER.debug("\n------END "+method_name+"---------\n")
  end
end