require 'sforce/rest/Surveys2'

class PagesController < ApplicationController
  def home
    @title = 'Home'
  end

  def contact
    @title = 'Contact'
  end
  
  def about
    @title = 'About'
  end

  def help
    @title = 'Help'
  end
   
  def tests
    surveyc = Surveys2.new(current_user)
    @AllSurveys = surveyc.get_user_surveys
  end

end
