class CommentsController < ApplicationController
  before_action :set_message

  def create
    if @comment = @message.comments.create(content: params[:comment][:content], user: current_user)
      if @message.comments.playing.count > 0
        PusherService.add_track(@comment)
      else
        @comment.start_playing(true)
      end
    end
  end

  def destroy
    @comment = Comment.find_by(id: params[:id])
    PusherService.remove_track(@comment) if @comment && @comment.destroy
  end

  private

  def set_message
    unless @message = Message.find_by(id: params[:message_id])
      render nothing: true, status: :bad_request
    end
  end
end
