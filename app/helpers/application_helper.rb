module ApplicationHelper
  def push_track(comment)
    Pusher.trigger('message_' + comment.message.id.to_s, 'now_playing', {
      title:          comment.responses['title'].to_s,
      artist:         comment.responses['user']['username'].to_s,
      artwork_url:    comment.album_art_url,
      stream_url:     comment.responses['stream_url'].to_s + '?client_id=b59d1f4b68bbc8f2b0064188f210117d',
      background_url: comment.blurred_album_art_url,
      palette_url:    comment.palette_url,
      count:          comment.message.queue_count
    })
  end
end
