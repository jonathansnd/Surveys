class SurveysController < ApplicationController

  before_filter :authenticate, :only => [:builder,:preview]
  	
  def builder
    @title = 'Survey Builder'
  end

  def preview
    render :layout => 'surveypreview'  
    @title = 'Survey Preview'
  end

end
