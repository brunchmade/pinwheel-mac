class SessionsController < ApplicationController
  skip_before_action :ensure_authenticated_user, only: %i( new soundcloud create )

  def new
    # @users = User.all
  end

  def soundcloud
    if code = params[:code]
      access_token = Soundcloud.client.exchange_token(:code => code)
      client = Soundcloud.new(:access_token => access_token['access_token'])

      current_user = client.get('/me')
      p current_user
        user = User.find_by_name(current_user.username)
        if !user 
          user = User.create! name: current_user.username, soundcloud_token: access_token, soundcloud_response: current_user
        end
      p user.id

      authenticate_user(user.id)
      redirect_to message_path(Message.first)
    else
      redirect_to Soundcloud.client.authorize_url()
    end

  end

  def create
    authenticate_user(params[:user_id])
    redirect_to message_path(Message.first)
  end

  def destroy
    unauthenticate_user
    redirect_to root_url
  end
end
