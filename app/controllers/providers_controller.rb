class ProvidersController < ApplicationController
  before_action :require_auth, except: [:public_index]
  before_action :set_provider, only: [:show, :edit, :update, :destroy]

  # GET /providers
  # GET /providers.json
  def index
    @providers = Provider.where(user_id: session[:user]["id"])
    if params[:private_only]
      @providers = @providers.where(public: false)
    end
  end

  def public_index
    @providers = Provider.where(public: true)
    respond_to do |format|
      format.html
      format.json {render json: @providers}
    end
  end

  # GET /providers/1
  # GET /providers/1.json
  def show
  end

  # GET /providers/new
  def new
    @provider = Provider.new
    @provider.user_id = session[:user]["id"]
    @provider.redirect_uri = "#{request.base_url}/callback"
  end

  # GET /providers/1/edit
  def edit
  end

  # POST /providers
  # POST /providers.json
  def create
    @provider = Provider.new(provider_params)
    @provider.user_id = session[:user]["id"]
      begin
        # To avoid issues with Discovery Endpoints that do not support CORS, lets just
        # discover the info server-side, and populate the database with it
        @provider_info = OpenIDConnect::Discovery::Provider::Config.discover!(@provider.provider)
        logger.debug "provider info: #{@provider_info.inspect}"
        logger.debug "issuer: #{@provider.issuer} #{@provider.issuer.inspect} #{@provider.issuer.class}"
        if @provider.issuer.blank?
          @provider.issuer = @provider_info.issuer
        end
        if @provider.authorization_endpoint.blank?
          @provider.authorization_endpoint = @provider_info.authorization_endpoint
        end
        if @provider.userinfo_endpoint.blank?
          @provider.userinfo_endpoint = @provider_info.userinfo_endpoint
        end
        if @provider.jwks_uri.blank?
          @provider.jwks_uri = @provider_info.jwks_uri
        end
      rescue => e
        logger.error e.message
        flash[:error] = "Error with Provider Discovery: #{e.message} -- Fill in the rest of the manual endpoints!"
      end

    respond_to do |format|
      if @provider.save
        format.html { redirect_to @provider, notice: 'Provider was successfully created.' }
        format.json { render :show, status: :created, location: @provider }
      else
        format.html { render :new }
        format.json { render json: @provider.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /providers/1
  # PATCH/PUT /providers/1.json
  def update
    respond_to do |format|
      if @provider.update(provider_params)
        format.html { redirect_to @provider, notice: 'Provider was successfully updated.' }
        format.json { render :show, status: :ok, location: @provider }
      else
        format.html { render :edit }
        format.json { render json: @provider.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /providers/1
  # DELETE /providers/1.json
  def destroy
    @provider.destroy
    respond_to do |format|
      format.html { redirect_to providers_url, notice: 'Provider was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_provider
      @provider = Provider.where(user_id: session[:user]["id"], id: params[:id]).first
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def provider_params
      params.require(:provider).permit(:user_id, :public, :client_id, :redirect_uri, :provider, :issuer, :authorization_endpoint, :jwks_uri, :userinfo_endpoint, :name, :client_secret)
    end

    def require_auth
      unless session[:user]
        flash[:error] = "Adding a provider requires a RESO member account"
        redirect_to "/login"
      end
    end
end
