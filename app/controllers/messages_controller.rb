class MessagesController < ApplicationController
  def backfill
    @message = Message.find(params[:id])

    url = "https://api-v2.soundcloud.com/explore/Popular+Music?tag=out-of-experiment&limit=100&client_id=b59d1f4b68bbc8f2b0064188f210117d"
    resp = Net::HTTP.get_response(URI.parse(url))
    buffer = resp.body
    hash = JSON[buffer]
    tracks = hash['tracks'].sample(10)
    tracks.delete_if { |t| t['streamable'] == false}

    tracks.each do |comment|
      @comment = comment
      @comment = Comment.create! message: @message, content: @comment['permalink_url'], user: @current_user

      html = ApplicationController.render(
        assigns: { comment: @comment },
        template: 'comments/_comment',
        layout: false
      )
      Pusher.trigger('message_' + @comment.message.id.to_s, 'on_deck', {
        message: html
      })
    end


    playing = @message.comments.where(now_playing: true).first
    unless playing
      NextUpJob.perform_now(@message.id)
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
