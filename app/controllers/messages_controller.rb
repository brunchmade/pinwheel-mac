class MessagesController < ApplicationController
  def index
    @messages = Message.all
  end

  def show
    @message = Message.find(params[:id])
    @now_playing = Comment.where(now_playing: true).first
    @comments = Comment.where(now_playing: false, aired_at: nil).order(created_at: :asc)
  end
end
