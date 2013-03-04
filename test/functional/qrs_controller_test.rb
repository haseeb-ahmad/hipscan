require 'test_helper'

class QrsControllerTest < ActionController::TestCase
  setup do
    @qr = qrs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:qrs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create qr" do
    assert_difference('Qr.count') do
      post :create, :qr => @qr.attributes
    end

    assert_redirected_to qr_path(assigns(:qr))
  end

  test "should show qr" do
    get :show, :id => @qr.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @qr.to_param
    assert_response :success
  end

  test "should update qr" do
    put :update, :id => @qr.to_param, :qr => @qr.attributes
    assert_redirected_to qr_path(assigns(:qr))
  end

  test "should destroy qr" do
    assert_difference('Qr.count', -1) do
      delete :destroy, :id => @qr.to_param
    end

    assert_redirected_to qrs_path
  end
end
