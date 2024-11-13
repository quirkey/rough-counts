require "test_helper"

class IngramParserControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get ingram_parser_index_url
    assert_response :success
  end
end
