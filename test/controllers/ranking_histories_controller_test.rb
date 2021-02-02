require 'test_helper'

class RankingHistoriesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get ranking_histories_index_url
    assert_response :success
  end

end
