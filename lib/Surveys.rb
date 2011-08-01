require 'httparty'
require 'base64'
require 'rexml/document'

class Surveys

  include HTTParty

  def initialize(current_user)
    @current_user = current_user
    @serviceauth = @current_user.services.find(:first, :conditions => { :provider => 'forcedotcom' })
    @accesstoken = nil
  end

  def print_response(name, response)
    puts '>>>> action : '+name
    puts '>>>> response : '+response.inspect
    puts '>>>> response Code : '+response.code.to_s
  end

  def set_headers
    Surveys.headers 'Authorization' => "OAuth #{@serviceauth.token}"
    Surveys.headers 'Content-Type' => "application/json"
  end

  def root_url
    @root_url = @serviceauth.instance_url+"/services/data/v"+ENV['sfdc_api_version']
  end

  def get_user_surveys

    puts '>>> SURVEY LIST >>> '

    set_headers
    #create survey
    soql = "SELECT Id, Name, Status__c, Description__c, Site_URL__c,Preview_URL__c, CreatedDate from Survey__c order by CreatedDate desc"
    resp = Surveys.get(root_url+"/query/?q=#{CGI::escape(soql)}")

    print_response('get_user_surveys',resp)
    return resp

  end

  def get_survey_xml(sid)

    puts '>>> SURVEY LOAD >>> '+sid

    Surveys.headers 'Authorization' => "OAuth #{@serviceauth.token}"
    Surveys.headers 'Content-Type' => "text/xml"

    #create survey
    soql = "SELECT Id,Name,body from Attachment where ParentId = \'#{sid}\' order by CreatedDate desc limit 1"
    attachment = Surveys.get(root_url+"/query/?q=#{CGI::escape(soql)}")

    print_response('get_survey_xml (Get Attachment)',attachment)

    attachmentid = attachment["records"][0]["Id"]
    resp = Surveys.get(root_url+"/sobjects/Attachment/#{attachmentid}/Body")

    print_response('get_survey_xml (Get Body)',resp)

    return resp

  end

  def create(params)

    #set default values for survey
    surveyid = ''
    surveyName  =  'Untitled'
    description = ''
  
    #get some of the data from the xml
    doc = REXML::Document.new(params[:srdf])

    #get title
    doc.elements.each('Survey/rdf:RDF/Survey/dc:title') do |ele|
       surveyName = ele.text
    end 
    #get description
    doc.elements.each('Survey/rdf:RDF/Survey/dc:description') do |ele|
       description = ele.text
    end 

    #get survey id
    surveyid  = params[:surveyid]

    #set request headers
    set_headers

    #initialize response as nil
    @resp = nil
    bSurveySaved = false

    if(surveyid != nil && surveyid.length > 0)
      
      puts '>>> SURVEY UPDATE >>> '+surveyid

       #update specified survey if we have the survey id in the parameters
      options = {
        :body => {
          :name => surveyName,
          :description__c => description,
          :status__c => 'Debug'
        }.to_json
      }

      #update survey
      result = Surveys.post(root_url+"/sobjects/survey__c/"+surveyid+"/?_HttpMethod=PATCH", options)
    
      print_response('Update survey result : ',result)

      if(result.code == 204)
        bSurveySaved = true
         @resp = {:id => surveyid, :code => result.code, :operation => 'update'}
      else
        @resp = {:id => '', :code => result.code, :operation => 'update'}
      end

    else

      puts '>>> NEW SURVEY INSERT >>>'

      #create a new survey if we dont have a survey id in the url
      options = {
        :body => {
          :name => surveyName,
          :description__c => description,
          :status__c => 'Debug'
        }.to_json
      }

      #create survey
      result = Surveys.post(root_url+"/sobjects/survey__c/", options)

      print_response('Insert survey result : ',result)

      if(result.code == 201)
        bSurveySaved = true
        surveyid = result["id"]
        @resp = {:id => surveyid, :code => result.code, :operation => 'insert'}
      else
        @resp = {:id => '', :code => result.code, :operation => 'insert'}
      end
        
    end

    #create attachment
    #if(@resp[0] == nil && @resp["success"])
    if(bSurveySaved)

      options = {
        :body => {
          :parentId => surveyid,
          :body => Base64.encode64(params[:srdf]),
          :name => 'surveyrdf.xml'
        }.to_json
      }
    
      #create survey
      respatt = Surveys.post(root_url+"/sobjects/Attachment/", options)
      print_response('Insert attachment result : ', respatt)
      
      #if(@respatt[0] != nil)
        #return @respatt   
      #end     

    end

    return @resp
    
  end

  
end