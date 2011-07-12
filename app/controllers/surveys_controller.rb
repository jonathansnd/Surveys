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
    surveyResponse = surveyService.create(params)

    #display results
    if(surveyResponse[0] == nil && surveyResponse["success"])
      flash[:success] = "Survey has been created!"
    else
      flash[:error] = "Oops there was an error : " + surveyResponse[0]["message"]
    end
    
    #return to export page
    redirect_to export_path

  end

end
