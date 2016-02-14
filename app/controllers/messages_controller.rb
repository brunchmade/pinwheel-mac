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
      @now_playing = Comment.first
    end
    @comments = Comment.where(now_playing: false, aired_at: nil, message_id: params[:id]).order(created_at: :asc)
  end
end
