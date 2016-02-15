class MessagesController < ApplicationController
  def next
    @message = Message.find(params[:id])
    @comment = @message.comments.where(now_playing: true).first
    NextUpJob.perform_now(@message.id, @comment.id)
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
      html = ApplicationController.render(
        assigns: { comment: @comment },
        template: 'comments/_comment',
        layout: false
      )
      Pusher.trigger('message_' + @comment.message.id.to_s, 'on_deck', {
        message: html,
        count: @message.queue_count
      })
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
    @message = Message.find(params[:id])
    playing = @message.comments.where(now_playing: true).first
    if playing
      @now_playing = playing
    else
      now = Time.now.utc
      if @now_playing = @message.comments.where(aired_at: nil).order(created_at: :asc).first
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
    @comments = @message.comments.where(now_playing: false, aired_at: nil).order(created_at: :asc)
  end
end
