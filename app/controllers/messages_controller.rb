class MessagesController < ApplicationController
  def index
    @messages = Message.all
  end

  def show
    @message = Message.find(params[:id])
    playing = Comment.where(now_playing: true, message_id: params[:id]).first
    if playing
      @now_playing = playing
    else
      now = Time.now.utc
      @now_playing = @message.comments.where(aired_at: nil).order(created_at: :asc).first
      @now_playing.update_attributes(now_playing: true, aired_at: now)
      next_track_at = now + (@now_playing.responses['duration'] / 1000).ceil
      NextUpJob.set(wait_until: next_track_at).perform_later(@message.id)
    end
    @comments = Comment.where(now_playing: false, aired_at: nil, message_id: params[:id]).order(created_at: :asc)
  end
end
