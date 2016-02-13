class NextUpJob < ApplicationJob
  queue_as :default

  def perform(*args)
    c = Comment.where(now_playing: true).first
    f = Comment.where(now_playing: false, aired_at: nil).order(created_at: :desc).last
    
    c.now_playing = false
    f.now_playing = true
    f.aired_at = Time.now.utc

    c.save
    f.save

    Pusher.trigger('message_' + f.message.id.to_s, 'now_playing', {
      title:          f.responses['title'].to_s,
      artist:         f.responses['user']['username'].to_s,
      artwork_url:    f.responses['artwork_url'].to_s.gsub('large','t500x500'),
      stream_url:     f.responses['stream_url'].to_s + '?client_id=b59d1f4b68bbc8f2b0064188f210117d'
    })
    # This should enqueue another job for this time
    # f.aired_at + (f.responses['duration'] / 1000)
  end
end
