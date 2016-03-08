class MessagesController < ApplicationController
  def backfill
    @message = Message.find(params[:id])

    url = "https://api-v2.soundcloud.com/explore/Popular+Music?tag=out-of-experiment&limit=100&client_id=#{ENV['SOUNDCLOUD_ID']}"
    resp = Net::HTTP.get_response(URI.parse(url))
    buffer = resp.body
    hash = JSON[buffer]
    tracks = hash['tracks'].sample(10)
    tracks.delete_if { |t| t['streamable'] == false}

    tracks.each do |comment|
      if @comment = @message.comments.create(content: comment['permalink_url'], user: current_user)
        if @message.comments.playing.count > 0
          PusherService.add_track(@comment)
        else
          @comment.start_playing(true)
        end
      end
    end
  end

  def index
    @messages = Message.all.order('lower(title) ASC')
  end

  def next
    if @message = Message.find_by(id: params[:id])
      if @comment = @message.comments.playing.first
        NextUpJob.perform_now(@message.id, @comment.id)
      end
    end
  end

  def reload_all
    PusherService.reload_all_rooms
  end

  def show
    @messages = Message.all.order('lower(title) ASC')

    if @message = Message.find_by(id: params[:id])
      if playing = @message.comments.playing.first
        @now_playing = playing
      else
        if @now_playing = @message.comments.enqueued.first
          @now_playing.start_playing(false)
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
