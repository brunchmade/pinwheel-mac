class NextUpJob < ApplicationJob
  include ApplicationHelper
  queue_as :default

  def perform(*args)
    c = Comment.where(now_playing: true).first
    f = Comment.where(now_playing: false, aired_at: nil).order(created_at: :desc).last
    
    if c
      c.now_playing = false
      c.save
    end

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
