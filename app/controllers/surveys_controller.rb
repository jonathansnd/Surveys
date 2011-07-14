require 'Surveys'

class SurveysController < ApplicationController

  before_filter :authenticate, :only => [:builder,:preview,:export,:createsurvey]
  	
  def builder
    @title = 'Survey Builder'
  end

  def preview
    render :layout => 'surveypreview'  
    @title = 'Survey Preview'
  end

  def export
  	@title = 'Survey Export'

  end

  def createsurvey

    #initialize survey service
    surveyService = Surveys.new(current_user)

    #create the survey
    resp = surveyService.create(params)

    #display results
    if(resp[0] == nil && resp["success"])
      serviceauth = current_user.services.find(:first, :conditions => { :provider => 'forcedotcom' })
      link = "<a href=\"#{serviceauth.instance_url}/#{resp["id"]}\" target=\"_blank\" class=\"detailsLink\">View details</a>"  
      flash[:success] = "Your survey has been created! #{link} "
      #redirect_to :controller => 'surveys', :action => 'export', :id => resp["id"]
    else
      flash[:error] = "Oops there was an error : " + resp[0]["message"]
    end

    redirect_to builder_path

  end

end
