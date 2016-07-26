require 'test_helper'

class SlideshowItemsControllerTest < ActionController::TestCase
  setup do
    @slideshow_item = slideshow_items(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:slideshow_items)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create slideshow_item" do
    assert_difference('SlideshowItem.count') do
      post :create, slideshow_item: @slideshow_item.attributes
    end

    assert_redirected_to slideshow_item_path(assigns(:slideshow_item))
  end

  test "should show slideshow_item" do
    get :show, id: @slideshow_item.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @slideshow_item.to_param
    assert_response :success
  end

  test "should update slideshow_item" do
    put :update, id: @slideshow_item.to_param, slideshow_item: @slideshow_item.attributes
    assert_redirected_to slideshow_item_path(assigns(:slideshow_item))
  end

  test "should destroy slideshow_item" do
    assert_difference('SlideshowItem.count', -1) do
      delete :destroy, id: @slideshow_item.to_param
    end

    assert_redirected_to slideshow_items_path
  end
end
