require 'test_helper'

class PoliceControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:police)
  end

  test "should get new" do
    get :new, :cjenik => :racunala
    assert_response :success
  end
end
