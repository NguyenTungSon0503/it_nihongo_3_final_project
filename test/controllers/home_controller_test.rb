require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get home_index_url
    assert_response :success
  end

  test "should get lookup" do
    get home_lookup_url
    assert_response :success
  end

  test "should get table" do
    get home_table_url
    assert_response :success
  end
end
