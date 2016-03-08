class SessionsController < ApplicationController
  before_action :ensure_authenticated_user, only: [:destroy]

  def destroy
    unauthenticate_user
    redirect_to root_url
  end

  def new
    redirect_to(message_path(Message.first)) if current_user
  end

  def soundcloud
    unless code = params[:code].presence
      redirect_to Soundcloud.client.authorize_url()
      return
    end

    access_token = Soundcloud.client.exchange_token(code: code)
    client = Soundcloud.new(access_token: access_token['access_token'])

    soundcloud_user = client.get('/me')
    user = User.find_by(name: soundcloud_user.username)
    unless user
      user = User.create(name: soundcloud_user.username, soundcloud_token: access_token, soundcloud_response: soundcloud_user)
    end

    authenticate_user(user.id) if user
    redirect_to message_path(Message.first)
  end

end
