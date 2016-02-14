class MessagesController < ApplicationController
  def index
    @messages = Message.all
  end

  def show
    @message = Message.find(params[:id])
    playing = @message.comments.where(now_playing: true).first
    if playing
      @now_playing = playing
    else
      now = Time.now.utc
      if @now_playing = @message.comments.where(aired_at: nil).order(created_at: :asc).first
        @now_playing.update_attributes(now_playing: true, aired_at: now)
        next_track_at = now + (@now_playing.responses['duration'] / 1000).ceil
        NextUpJob.set(wait_until: next_track_at).perform_later(@message.id)
      else
        @now_playing = Comment.new(responses: {
          artwork_url: 'https://i1.sndcdn.com/artworks-000127422318-y9zmkl-large.jpg',
          title: 'Rick and Morty',
          user: {
            username: 'Tumtable'
          },
          stream_url: ''
        })
      end
    end
    @comments = @message.comments.where(now_playing: false, aired_at: nil).order(created_at: :asc)
  end
end
