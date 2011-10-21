require 'test_helper'

class WelcomeControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  context 'Get landing page' do
    setup {get :index}

    should respond_with(:success)
  end

  test "should get services" do
    get :services
    assert_response :success
  end

  test "should get video services" do
    get :video_services
    assert_response :success
  end

  test "should get mobile services" do
    get :mobile_services
    assert_response :success
  end

  test "should get design services" do
    get :design_services
    assert_response :success
  end

  test "should get getinfo" do
    get :getinfo
    assert_response :success
  end

  test "should post getinfo" do
    post :getinfo, :username => 'test', :email => 'test@test.org', :description => 'Desc'
    assert_response :redirect
  end

  test "should get services thankyou" do
    get :services_thankyou
    assert_response :success
  end

end
