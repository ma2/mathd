require "test_helper"

class QControllerTest < ActionDispatch::IntegrationTest
  test "should get main" do
    get q_main_url
    assert_response :success
  end

  test "should get ranking" do
    get q_ranking_url
    assert_response :success
  end
end
