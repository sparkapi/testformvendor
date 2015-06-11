json.array!(@providers) do |provider|
  json.extract! provider, :id, :user_id, :public, :client_id, :redirect_uri, :provider, :issuer, :authorization_endpoint, :jwks_uri, :userinfo_endpoint, :name
  json.url provider_url(provider, format: :json)
end
