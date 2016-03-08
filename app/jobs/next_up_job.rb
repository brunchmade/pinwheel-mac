class NextUpJob < ApplicationJob
  queue_as :default

  def perform(message_id, comment_id)
    message = Message.find(message_id)
    comment = Comment.find(comment_id)
    playing = message.comments.playing.first

    if comment.id == playing.id
      playing.now_playing = false
      playing.save

      if next_comment = message.comments.enqueued.first
        next_comment.start_playing(true)
      end
    end
  end
end
