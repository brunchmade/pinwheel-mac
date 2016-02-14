module ApplicationHelper
  def push_track(comment)
    Pusher.trigger('message_' + comment.message.id.to_s, 'now_playing', {
      title:          comment.responses['title'].to_s,
      artist:         comment.responses['user']['username'].to_s,
      artwork_url:    comment.responses['artwork_url'].to_s.gsub('large','t500x500'),
      stream_url:     comment.responses['stream_url'].to_s + '?client_id=b59d1f4b68bbc8f2b0064188f210117d',
      background_url: comment.responses['artwork_url'].to_s.gsub('large','t500x500').gsub('https://i1.sndcdn.com', 'https://tumtable.imgix.net') + '?blur=200',
      palette_url:    comment.responses['artwork_url'].to_s.gsub('large','t500x500').gsub('https://i1.sndcdn.com', 'https://tumtable.imgix.net') + '?colorquant=2&palette=css&colors=2&class=album&zoom=100'
    })
  end
end
