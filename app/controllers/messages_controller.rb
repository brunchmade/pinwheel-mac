class MessagesController < ApplicationController
  before_action :set_message, only: [
    :backfill,
    :next,
    :update_user_count
  ]

  def backfill
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

  def create
    @message = Message.create message_params
    redirect_to @message
  end

  def index
    @messages = Message.all.order('lower(title) ASC')
  end

  def next
    if @comment = @message.comments.playing.first
      NextUpJob.perform_now(@message.id, @comment.id)
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

  def update_user_count
    user_count = params[:user_count].presence || 0
    user_count = user_count.to_i
    if user_count > @message.most_users_count
      @message.update_attributes(most_users_count: user_count)
    end
    render json: {user_count: @message.most_users_count}, status: :ok
  end

  private

  def message_params
    params.require(:message).permit(:title)
  end

  def set_message
    unless @message = Message.find_by(id: params[:id])
      render nothing: true, status: :bad_request
    end
  end
end
