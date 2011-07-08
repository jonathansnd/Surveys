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

  def builder
    @title = 'Survey Builder'
  end

  def preview
    @title = 'Survery Preview'
  end
      
end
