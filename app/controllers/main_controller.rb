class MainController < ApplicationController
  protect_from_forgery with: :null_session, only: [:properties]
  def index
    @public_providers = Provider.where(public: true)
    reset_tokens
  end

  def callback
    # Running in Authorization Code mode.  
    # Start the code flow using the provider's token_endpoint
    if cookies['issuer'] && params[:code]
      discover_provider(cookies['issuer'])
      # swap code for access/refresh/id token
      authorization_code_flow
      # Use the access token to get claims from userinfo endpoint
      userinfo_call
      # Use the access token to get some properties
      @properties = spark_properties_call
    end
  end

  def properties
    render :json => spark_properties_call 
  end

  # Display a partial diagram for AJAX calls
  def diagram
    @flow = params[:flow]
    render layout: "diagram"
  end

  private

  def reset_tokens
    [:id_token, 
     :access_token, 
     :refresh_token,
     :userinfo,
     :expires_in].each do |key|
      session.delete(key)
    end
    cookies.delete('issuer')
    cookies.delete('provider_id')
  end

  def discover_provider(issuer)
    @provider_info = OpenIDConnect::Discovery::Provider::Config.discover!(issuer)
    logger.debug "issuer discovery #{issuer} => #{@provider_info.inspect}"
  end

  # Perform the authorization code token exchange with the
  # OIDC Provider's token endpoint
  def authorization_code_flow
    logger.debug "cookie provider_id: #{cookies["provider_id"]}"
    if cookies["provider_id"]
      key_info = Provider.where(id: cookies["provider_id"]).first
    else
      key_info = KEY_CONFIG[ @provider_info.issuer ]
    end
    logger.debug "key info: #{key_info.inspect}"
    # Hit the token endpoint and save the returned access/refresh/id tokens
    tokens = token_call(
      token_endpoint: @provider_info.token_endpoint,
      client_id: key_info['client_id'],
      client_secret: key_info['client_secret'],
      code: params[:code],
      redirect_uri: key_info['redirect_uri']
    )
    logger.debug "tokens: #{tokens.inspect}"
    return nil if ! tokens
    if tokens[:error]
      session[:id_token] = "Error: #{tokens[:error]} => #{tokens[:error_description]}"
      return nil
    end
    session[:id_token] = decode_id_token(tokens[:id_token])
    session[:access_token] = tokens[:access_token]
    session[:refresh_token] = tokens[:refresh_token]
    session[:expires_in] = tokens[:expires_in].to_i

  end

  # Make a call to the specified userinfo endpoint and
  # return a nested hash of claims
  def userinfo_call
    return nil unless session[:access_token]
    c = Curl::Easy.new(@provider_info.userinfo_endpoint)
    c.resolve_mode = :ipv4
    c.headers = { authorization: "Bearer #{session[:access_token]}" }
    c.perform
    if c.body_str
      body_pretty = JSON.pretty_generate( JSON.parse( c.body_str ) )
      if c.response_code != 200
        session[:userinfo] = "Error #{c.response_code}:\n#{body_pretty}"
      else
        session[:userinfo] = body_pretty
      end
      logger.debug "userinfo: #{session[:userinfo].inspect}"
    end
  end

  # Make a call to the specified token endpoint
  # return hash with access/refresh/id tokens
  def token_call(options={})
    c = Curl::Easy.new(options[:token_endpoint])
    c.resolve_mode = :ipv4
    qs = URI.decode({
      grant_type: "authorization_code",
      client_id: options[:client_id],
      client_secret: options[:client_secret],
      code: options[:code],
      redirect_uri: options[:redirect_uri]
    }.to_query)
    logger.debug "token call query string: #{qs}"
    c.http_post(qs)
    if c.response_code != 200
      logger.error "token call Response code from #{options[:token_endpoint]} is #{c.response_code}"
      logger.error "body: #{c.body_str}"
      return nil
    end
    if c.body_str
      obj = JSON.parse(c.body_str)
      obj.symbolize_keys!
      return obj
    end
  end

  # Take an encoded ID Token, decode & verify it, and return
  # JSON text of the claims
  def decode_id_token(id_token)
    e = nil
    # Iterate all of the provider's public keys and try them until success
    @provider_info.public_keys.each do |key|
      begin
        id_obj = OpenIDConnect::ResponseObject::IdToken.decode id_token, key
        if id_obj.valid?
          return JSON.pretty_generate(JSON.parse(id_obj.to_json))
        end
      rescue => e
        logger.info "Invalid ID Token: #{e.message}"
      end
    end
    raise e if e
  end

  # Using the Spark API gem, grab some properties
  def spark_properties_call
    begin
      access_token = params[:access_token] || session[:access_token]
      if access_token
        expires = (session[:expires_in] || params[:expires_in] || 3600).to_i
        logger.debug "spark_properties_call using access token #{access_token} and expiration #{expires}"
        SparkApi.client.session = SparkApi::Authentication::OAuthSession.new(
          "access_token"=> access_token, 
          "expires_in" => expires)
      # An authorization code flow was given
      elsif params[:code]
        logger.debug "spark_properties_call using code #{params[:code]}"
        SparkApi.client.oauth2_provider.code = params[:code]
        SparkApi.client.authenticate
      else
        SparkApi.client.session = nil
        return '{error: "Spark API unauthenticated"}'
      end
      listings = SparkApi.client.get("/listings", _limit: 2).results
      compacted = listings.compact_recursive
      return JSON.pretty_generate(JSON.parse(compacted.to_json))
    rescue => e
      logger.error "Spark Properties: #{e.message} #{e.backtrace.join("\n")}"
      if e.message == "To be implemented by client application"
        return "{error: \"The token you provided is invalid.  A new authorization is required.\"}"
      else
        return "{error: \"#{e.message}\"}"
      end
    end
  end
  
end
