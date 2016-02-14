class NextUpJob < ApplicationJob
  include ApplicationHelper
  queue_as :default

  def perform(message_id)
    message = Message.find(message_id)
    playing = message.comments.where(now_playing: true)

    playing.each do |c|
      c.now_playing = false
      c.save
    end

    if f = message.comments.where(now_playing: false, aired_at: nil).order(created_at: :asc).first
      now = Time.now.utc

      f.now_playing = true
      f.aired_at = now
      f.save

      next_track_at = now + (f.responses['duration'] / 1000).ceil
      NextUpJob.set(wait_until: next_track_at).perform_later(message.id)

      push_track(f)
    end
  end
end
