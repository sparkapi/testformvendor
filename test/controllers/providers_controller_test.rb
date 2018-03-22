require 'test_helper'

class ProvidersControllerTest < ActionController::TestCase
  setup do
    @provider = providers(:one)
    session[:user] = users(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:providers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create provider" do
    assert_difference('Provider.count') do
      post :create, provider: { authorization_endpoint: @provider.authorization_endpoint, client_id: @provider.client_id, issuer: @provider.issuer, jwks_uri: @provider.jwks_uri, provider: @provider.provider, public: @provider.public, redirect_uri: @provider.redirect_uri, user_id: @provider.user_id, userinfo_endpoint: @provider.userinfo_endpoint }
    end

    assert_redirected_to provider_path(assigns(:provider))
  end

  test "should show provider" do
    get :show, id: @provider
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @provider
    assert_response :success
  end

  test "should update provider" do
    patch :update, id: @provider, provider: { authorization_endpoint: @provider.authorization_endpoint, client_id: @provider.client_id, issuer: @provider.issuer, jwks_uri: @provider.jwks_uri, provider: @provider.provider, public: @provider.public, redirect_uri: @provider.redirect_uri, user_id: @provider.user_id, userinfo_endpoint: @provider.userinfo_endpoint }
    assert_redirected_to provider_path(assigns(:provider))
  end

  test "should destroy provider" do
    assert_difference('Provider.count', -1) do
      delete :destroy, id: @provider
    end

    assert_redirected_to providers_path
  end
end
