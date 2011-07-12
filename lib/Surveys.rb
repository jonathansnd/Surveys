require 'httparty'
require 'base64'

class Surveys

  include HTTParty

  format :json

  def initialize(current_user)
    @current_user = current_user
    @serviceauth = @current_user.services.find(:first, :conditions => { :provider => 'forcedotcom' })
    @accesstoken = nil
  end

  def set_headers
    Surveys.headers 'Authorization' => "OAuth #{@serviceauth.token}"
    Surveys.headers 'Content-Type' => "application/json"
  end

  def root_url
    @root_url = @serviceauth.instance_url+"/services/data/v"+ENV['sfdc_api_version']
  end

  def create(params)

    set_headers
    options = {
      :body => {
        :name => params[:name]
      }.to_json
    }
    
    #create survey
    @resp = Surveys.post(root_url+"/sobjects/survey__c/", options)

      #create attachment
    if(@resp[0] == nil && @resp["success"])
        
      options = {
        :body => {
          :parentId => @resp["id"],
          :body => Base64.encode64(params[:srdf]),
          :name => 'surveyrdf.xml'
        }.to_json
      }
    
      #create survey
      @respatt = Surveys.post(root_url+"/sobjects/Attachment/", options)
      
      if(@respatt[0] != nil)
        return @respatt   
      end     

    end

    return @resp
    
  end

  
end