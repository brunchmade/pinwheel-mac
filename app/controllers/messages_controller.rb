class MessagesController < ApplicationController
  def next
    @message = Message.find(params[:id])
    @comment = @message.comments.where(now_playing: true).first
    NextUpJob.perform_now(@message.id, @comment.id)
  end

  def reload_all
    PusherService.reload_all_rooms
  end

  def backfill
    @message = Message.find(params[:id])

    url = "https://api-v2.soundcloud.com/explore/Popular+Music?tag=out-of-experiment&limit=100&client_id=b59d1f4b68bbc8f2b0064188f210117d"
    resp = Net::HTTP.get_response(URI.parse(url))
    buffer = resp.body
    hash = JSON[buffer]
    tracks = hash['tracks'].sample(10)
    tracks.delete_if { |t| t['streamable'] == false}

    tracks.each do |comment|
      @comment = @message.comments.create! content: comment['permalink_url'], user: @current_user
      PusherService.add_track(@comment)
    end

    playing = @message.comments.where(now_playing: true).order(created_at: :asc).first
    unless playing
      NextUpJob.perform_now(@message.id, @comment.id)
    end
  end

  def index
    @messages = Message.all
  end

  def show
    @messages = Message.all

    @message = Message.find(params[:id])
    playing = @message.comments.where(now_playing: true).first
    if playing
      @now_playing = playing
    else
      now = Time.now.utc
      if @now_playing = @message.comments.enqueued.first
        @now_playing.update_attributes(now_playing: true, aired_at: now)
        next_track_at = now + (@now_playing.responses['duration'] / 1000).ceil
        NextUpJob.set(wait_until: next_track_at).perform_later(@message.id, @now_playing.id)
      else
        @now_playing = Comment.new(responses: {
          artwork_url: '/default.png',
          title: 'Add some songs',
          user: {
            username: 'Keep the music flowing!'
          },
          stream_url: ''
        })
      end
    end
    @comments = @message.comments.enqueued
  end

  def create
    @message = Message.create message_params
    redirect_to @message
  end

  private

  def message_params
    params.require(:message).permit(:title)
  end
end
