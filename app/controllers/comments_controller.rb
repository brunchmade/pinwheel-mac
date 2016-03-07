class CommentsController < ApplicationController
  include ApplicationHelper

  before_action :set_message

  def destroy
    @comment = Comment.find(params[:id])
    Pusher.trigger('message_' + @comment.message.id.to_s, 'remove_on_deck', {
      id: @comment.id,
      count: (@message.queue_count - 1).to_s
    })
    @comment.destroy
  end

  def create
    @comment = @message.comments.create!(content: params[:comment][:content], user: @current_user)
    playing = @message.comments.where(now_playing: true).first

    if playing
      html = ApplicationController.render(
        assigns: { comment: @comment },
        template: 'comments/_comment',
        layout: false
      )
      Pusher.trigger('message_' + @comment.message.id.to_s, 'on_deck', {
        message: html,
        count: @message.queue_count.to_s
      })
    else
      now = Time.now.utc
      @comment.update_attributes(now_playing: true, aired_at: now)
      next_track_at = now + (@comment.responses['duration'] / 1000).ceil
      NextUpJob.set(wait_until: next_track_at).perform_later(@message.id, @comment.id)

      push_track(@comment)
    end
  end

  private
    def set_message
      @message = Message.find(params[:message_id])
    end
end
