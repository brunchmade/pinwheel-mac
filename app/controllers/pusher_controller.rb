class PusherController < ApplicationController
  protect_from_forgery :except => :auth # stop rails CSRF protection for this action

  def auth
    if @current_user
      response = Pusher[params[:channel_name]].authenticate(params[:socket_id], {
        user_id: @current_user.id,
        user_info: {
          name: @current_user.full_name,
          avatar_url: @current_user.soundcloud_response['avatar_url']
        }
      })
      render :json => response
    else
      render :text => "Not authorized", :status => '403'
    end
  end
end
