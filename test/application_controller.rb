class ApplicationController < ActionController::Base
  protect_from_forgery

  def normal
  end

  def no_layout
    render :normal, :layout => false
  end

  def variables
    @hello = "Hello world!"
  end

  def content_for
  end
end
