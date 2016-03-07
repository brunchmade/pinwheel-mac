class CommentsController < ApplicationController
  before_action :set_message

  def destroy
    @comment = Comment.find(params[:id])
    PusherService.remove_track(@comment) if @comment.destroy
  end

  def create
    @comment = @message.comments.create!(content: params[:comment][:content], user: @current_user)

    if @message.comments.where(now_playing: true).count > 0
      PusherService.add_track(@comment)
    else
      now = Time.now.utc
      @comment.update_attributes(now_playing: true, aired_at: now)
      next_track_at = now + (@comment.responses['duration'] / 1000).ceil
      NextUpJob.set(wait_until: next_track_at).perform_later(@message.id, @comment.id)
      PusherService.now_playing_track(@comment)
    end
  end

  private

  def set_message
    @message = Message.find(params[:message_id])
  end
end
