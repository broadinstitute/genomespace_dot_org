require 'test_helper'

class GuideSectionsControllerTest < ActionController::TestCase
  setup do
    @guide_section = guide_sections(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:guide_sections)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create guide_section" do
    assert_difference('GuideSection.count') do
      post :create, guide_section: @guide_section.attributes
    end

    assert_redirected_to guide_section_path(assigns(:guide_section))
  end

  test "should show guide_section" do
    get :show, id: @guide_section.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @guide_section.to_param
    assert_response :success
  end

  test "should update guide_section" do
    put :update, id: @guide_section.to_param, guide_section: @guide_section.attributes
    assert_redirected_to guide_section_path(assigns(:guide_section))
  end

  test "should destroy guide_section" do
    assert_difference('GuideSection.count', -1) do
      delete :destroy, id: @guide_section.to_param
    end

    assert_redirected_to guide_sections_path
  end
end
