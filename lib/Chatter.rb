require 'httparty'

class Chatter
  include HTTParty
  #doesn't seem to pick up env variable correctly if I set it here
  #headers 'Authorization' => "OAuth #{ENV['sfdc_token']}"
  format :json
  #debug_output $stderr

  def self.set_headers
    payload = 'grant_type=refresh_token' + '&client_id=' + ENV['sfdc_consumer_key']+ '&client_secret=' + ENV['sfdc_consumer_secret'] + '&refresh_token=' + ENV['sfdc_token_refresh']
    result = post('https://login.salesforce.com/services/oauth2/token',:body => payload)
    headers 'Authorization' => "OAuth #{result['access_token']}"
  end

  def self.root_url
    @root_url = ENV['sfdc_instance_url']+"/services/data/v"+ENV['sfdc_api_version']+"/chatter"
  end

  def self.get_users_info(id)
    Chatter.set_headers
    @resp = get(Chatter.root_url+"/users/"+id)
    return @resp
  end

  def self.get_my_info
    Chatter.get_users_info("me")
  end
  
  def self.get_newsfeed(id)
    Chatter.set_headers
    @resp = get(Chatter.root_url+"/feeds/news/"+id)
    Chatter.log_response(@resp, "get_newsfeed")
    return @resp
  end
    
  def self.get_my_newsfeed
    Chatter.get_newsfeed("me")
  end
  
  def self.set_my_user_status(post)
    post(Chatter.root_url+"/feeds/news/me/feed-items?text="+CGI::escape(post.body))
  end
  
  def self.like_feeditem(id)
    post(Chatter.root_url+"/feed-items/"+id+"/likes")
  end
  
  def self.unlike_feeditem(id)
    delete(Chatter.root_url+"/feed-items/"+id+"/likes")
  end
  
  def self.add_comment(comment)
    post(Chatter.root_url+"/feed-items/"+comment.feeditemid+
         "/comments?text="+CGI::escape(comment.body))
  end
  
  
  #pre rel chatter page results returns the incorrect json response. it should be [feeditems][items]
  #like everything else, but it is just [items] so lets wrap it to make it consistent
  def self.get_page_of_feed(refpath)
    Chatter.set_headers
    
     @feed = Hash.new{}
      @feed["feedItems"] = Hash.new{} 
      
       @feed["feedItems"] = get(ENV['sfdc_instance_url']+refpath)
       return @feed
  end
  
  def self.log_response(resp, method_name)
    CHATTER_LOGGER.debug("\n------START "+method_name+"---------\n")
    CHATTER_LOGGER.debug(resp)
    CHATTER_LOGGER.debug("\n------END "+method_name+"---------\n")
  end
end