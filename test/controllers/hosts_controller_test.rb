require "test_helper"

class HostsControllerTest < ActionDispatch::IntegrationTest
  test "should get events" do
    get hosts_events_url
    assert_response :success
  end
end
