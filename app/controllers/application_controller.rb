# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  include ActionView::Helpers::NumberHelper
  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  def to_c(number)
      number_with_precision(number, :precision => 2, :delimiter => '.', :separator => ',') + ' kn' 
  end
protected
  def default_or_ajax
    return "application" if params[:ajax].nil?
    return nil
  end
end
