class NextUpJob < ApplicationJob
  include ApplicationHelper
  queue_as :default

  def perform()
    playing = Comment.where(now_playing: true, message_id: 1)
    playing.each do |c|
      c.now_playing = false
      c.save
    end

    f = Comment.where(message_id: 1, now_playing: false, aired_at: nil).order(created_at: :desc).last
    if f
      f.now_playing = true
      f.aired_at = Time.now.utc
      f.save

      next_track_at = Time.now.utc + (f.responses['duration'] / 1000)
      NextUpJob.set(wait_until: next_track_at).perform_later

      push_track(f)
    end
  end
end
