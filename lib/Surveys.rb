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
    soql = "SELECT Id,Name,(select id from Attachments) from Survey_RDF__c where Survey__c = \'#{sid}\' order by CreatedDate desc limit 1"
    surveyRDF = Surveys.get(root_url+"/query/?q=#{CGI::escape(soql)}")

    print_response('get_survey_xml (Get Survey RDF)',surveyRDF)

    attachment = surveyRDF["records"][0]["Attachments"]["records"][0]

    attachmentid = attachment["Id"]
    resp = Surveys.get(root_url+"/sobjects/Attachment/#{attachmentid}/Body")

    print_response('get_survey_xml (Get Body)',resp)

    return resp

  end

  def create(params)

    #set default values for survey
    surveyid = ''
    surveyName  =  'Untitled'
    description = ''
    surveyMode = ''
  
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
    #get mode
    doc.elements.each('Survey/rdf:RDF/Survey/mode') do |ele|
       surveyMode = ele.text
    end 

    #get survey id
    surveyid  = params[:surveyid]

    #set request headers
    set_headers

    #initialize response as nil
    @resp = nil
    bSurveySaved = false

    if(surveyid != nil && surveyid.length > 0)
      
      surveyid = surveyid.sub('#','')
      
      puts '>>> SURVEY UPDATE >>> '+surveyid
      
       #update specified survey if we have the survey id in the parameters
      options = {
        :body => {
          :name => surveyName,
          :description__c => description,
          :status__c => surveyMode,
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
          :status__c => surveyMode,
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
    if(bSurveySaved)

      #get survey version
      soql = "SELECT Id,Latest_Version__c,Active_Version__c from Survey__c where id = \'#{surveyid}\'"
      sfSurvey = Surveys.get(root_url+"/query/?q=#{CGI::escape(soql)}")
      
      print_response('Survey Query result : ',sfSurvey)

      surveyVersion = 1.0
      if(sfSurvey["records"][0]["Latest_Version__c"] != nil)
        surveyVersion += sfSurvey["records"][0]["Latest_Version__c"]
      end

      options = {
        :body => {
          :Survey__c => surveyid,
          :name => 'Survey RDF V'+surveyVersion.to_s,
          :version__c =>  surveyVersion,
          :is_active__c => false
        }.to_json
      }

      #create survey RDF
      result = Surveys.post(root_url+"/sobjects/Survey_RDF__c/", options)

      print_response('Create Survey RDF Response : ',result )
      
      if(result.code == 201)

        surveyRDFid = result["id"]
 
        options = {
          :body => {
            :name => 'surveyrdf.xml',
            :parentId => surveyRDFid,
            :body => Base64.encode64(params[:srdf])
          }.to_json
        }
             
        #create survey attachment
        respatt = Surveys.post(root_url+"/sobjects/Attachment/", options)
        print_response('Insert attachment result : ', respatt)

        #Activate Survey RDF
        options = {
          :body => {
            :is_active__c => true
          }.to_json
        }

        #update survey
        result = Surveys.post(root_url+"/sobjects/survey_rdf__c/"+surveyRDFid+"/?_HttpMethod=PATCH", options)

        print_response('Update attachment result : ', result)
        
      end

    end

    return @resp
    
  end

  
end