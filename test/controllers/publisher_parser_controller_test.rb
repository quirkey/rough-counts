require "test_helper"

class PublisherParserControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get publisher_parser_index_url
    assert_response :success
  end
end
