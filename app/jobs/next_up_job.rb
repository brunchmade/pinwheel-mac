class NextUpJob < ApplicationJob
  include ApplicationHelper
  queue_as :default

  def perform(message_id, comment_id)
    comment = Comment.find(comment_id)
    message = Message.find(message_id)
    playing = message.comments.where(now_playing: true).first

    if comment.id == playing.id
      playing.now_playing = false
      playing.save

      if f = message.comments.enqueued.first
        now = Time.now.utc

        f.now_playing = true
        f.aired_at = now
        f.save

        next_track_at = now + (f.responses['duration'] / 1000).ceil
        NextUpJob.set(wait_until: next_track_at).perform_later(message.id, f.id)

        push_track(f)
      end
    end
  end
end
