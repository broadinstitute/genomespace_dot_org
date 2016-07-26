require 'test_helper'

class ServerPropertiesControllerTest < ActionController::TestCase
  setup do
    @server_property = server_properties(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:server_properties)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create server_property" do
    assert_difference('ServerProperty.count') do
      post :create, server_property: { content: @server_property.content }
    end

    assert_redirected_to server_property_path(assigns(:server_property))
  end

  test "should show server_property" do
    get :show, id: @server_property
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @server_property
    assert_response :success
  end

  test "should update server_property" do
    put :update, id: @server_property, server_property: { content: @server_property.content }
    assert_redirected_to server_property_path(assigns(:server_property))
  end

  test "should destroy server_property" do
    assert_difference('ServerProperty.count', -1) do
      delete :destroy, id: @server_property
    end

    assert_redirected_to server_properties_path
  end
end
