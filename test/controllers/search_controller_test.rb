require 'test_helper'

class SearchControllerTest < ActionController::TestCase
  test "should get init" do
    get :init
    assert_response :success
  end

end
