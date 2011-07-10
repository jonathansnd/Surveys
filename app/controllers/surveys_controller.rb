class SurveysController < ApplicationController
	
  def builder
    @title = 'Survey Builder'
  end

  def preview
    render :layout => 'surveypreview'  
    @title = 'Survey Preview'
  end

end
