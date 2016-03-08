class PusherController < ApplicationController
  protect_from_forgery with: :null_session # Stops Rails CSRF protection

  def auth
    unless current_user
      render text: 'Not authorized', status: :unauthorized
      return
    end

    response = Pusher[params[:channel_name]].authenticate(params[:socket_id], {
      user_id: current_user.id,
      user_info: {
        name: current_user.full_name,
        avatar_url: current_user.soundcloud_response['avatar_url']
      }
    })

    render json: response
  end
end
