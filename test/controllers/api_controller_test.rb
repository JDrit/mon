require 'test_helper'

class ApiControllerTest < ActionController::TestCase
  test "should get comp_usage" do
    get :comp_usage
    assert_response :success
  end

end
