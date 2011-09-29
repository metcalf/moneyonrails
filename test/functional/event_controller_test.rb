require File.dirname(__FILE__) + '/../test_helper'
require 'event_controller'

# Re-raise errors caught by the controller.
class EventController; def rescue_action(e) raise e end; end

class EventControllerTest < Test::Unit::TestCase
  fixtures :accounts, :account_types, :events_accounts, :events, :user_accounts, :users
  
  def setup
    @controller = EventController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_create
    get :create, 
        {"commit"=>"Submit Transaction", "account"=>{"0"=>{"event_id"=>113, "account_id"=>21, "id"=>"", "amount"=>274.93, "is_credit"=>"1"}, "1"=>{"event_id"=>113, "name"=>"Andrew Expenses|Marc Metcalf|", "id"=>"", "is_credit"=>"0", "amt"=>"274.93"}}, "event"=>{"due(1i)"=>"", "name"=>"Initial Balances - Parents", "due(2i)"=>"", "moment(1i)"=>"2007", "due(3i)"=>"", "moment(2i)"=>"5", "moment(3i)"=>"25", "user_id"=>4}},
        { "user" => 4 }
    assert_response :success
    event = Event.find_by_name("Initial Balances - Parents")
    assert_not_nil event
    
    assert event.validate
  end
  
  def test_getAcct
    assert_not_null @controller.getAcct("Assets")
  end
  # Replace this with your real tests.
end
