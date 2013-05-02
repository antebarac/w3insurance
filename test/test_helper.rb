ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'rails/test_help'

class ActiveSupport::TestCase
  fixtures :all

  # Add more helper methods to be used by all tests here...
  
  include ActionView::Helpers::NumberHelper
  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  def to_c(number)
      number_with_precision(number, :precision => 2, :delimiter => '.', :separator => ',') + ' kn' 
  end
  
end
