class AuthenticationsController < ApplicationController
  # GET /authentications
  # GET /authentications.json
  def index
    @authentications = current_user.authentications if current_user

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @authentications }
    end
  end

  # GET /authentications/1
  # GET /authentications/1.json
  def show
    @authentication = Authentication.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @authentication }
    end
  end

  # GET /authentications/new
  # GET /authentications/new.json
  def new
    @authentication = Authentication.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @authentication }
    end
  end

  # GET /authentications/1/edit
  def edit
    @authentication = Authentication.find(params[:id])
  end

  # POST /authentications
  # POST /authentications.json
  def create

    auth = request.env["omniauth.auth"]
    token = auth["credentials"]["token"]
    secret = auth["credentials"]["secret"]

    current_user.authentications.build(:provider => auth['provider'], :uid => auth['uid'], 
     :token => token, :secret => secret)
    if current_user.save
      Twitter.configure do |config|
        config.consumer_key = 'ubCmGXxyj0ZQ2guzFXdg'
        config.consumer_secret = 'ytoc7GZ05NqSgKZqpW0O1PjyCUiEuPrDuuHV0rLKE'
        config.oauth_token = token
        config.oauth_token_secret = secret
      end

      raise Twitter.home_timeline.first.text
      flash[:notice] = "Authentication successful."
    else
      flash[:notice] = "Authentication failed."
    end
    redirect_to dashboard_url
    

    # authentication = Authentication.find_by_provder_and_uid(auth['provider'], auth['uid'])
    # if authentication
    #   flash[:notice] = "Authentication successful."
    #   sign_in_and_redirect(:user, authentication.user)
    # else
    #   current_user.authentications.create(:provider => auth['provider'], :uid => auth['uid'])
    #   flash[:notice] = "Authentication successful"
    #   redirect_to authentications_url
    # end

    # respond_to do |format|
    #   if @authentication.save
    #     format.html { redirect_to @authentication, notice: 'Authentication was successfully created.' }
    #     format.json { render json: @authentication, status: :created, location: @authentication }
    #   else
    #     format.html { render action: "new" }
    #     format.json { render json: @authentication.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # PUT /authentications/1
  # PUT /authentications/1.json
  def update
    @authentication = Authentication.find(params[:id])

    respond_to do |format|
      if @authentication.update_attributes(params[:authentication])
        format.html { redirect_to @authentication, notice: 'Authentication was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @authentication.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /authentications/1
  # DELETE /authentications/1.json
  def destroy
    @authentication = current_user.authentications.find(params[:id])
    @authentication.destroy
    flash[:notice] = "Successfully destroyed authentication."
    redirect_to authentications_url
    respond_to do |format|
      format.html { redirect_to authentications_url }
      format.json { head :no_content }
    end
  end
end
