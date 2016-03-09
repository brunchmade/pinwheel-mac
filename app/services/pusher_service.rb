class PusherService
  class << self

    def now_playing_track(comment)
      message = comment.message
      Pusher.trigger("message_#{message.id}", 'now_playing', {
        title:          comment.responses['title'].to_s,
        artist:         comment.responses['user']['username'].to_s,
        artwork_url:    comment.album_art_url,
        permalink_url:  comment.responses['permalink_url'],
        stream_url:     "#{comment.responses['stream_url']}?client_id=#{ENV['SOUNDCLOUD_ID']}",
        background_url: comment.blurred_album_art_url,
        palette_url:    comment.palette_url,
        count:          message.queue_count.to_s
      })
    end

    def add_track(comment)
      message = comment.message
      html = ApplicationController.render(
        assigns: { comment: comment },
        template: 'comments/_comment',
        layout: false
      )
      Pusher.trigger("message_#{message.id}", 'on_deck', {
        message: html,
        count: message.queue_count.to_s
      })
    end

    def remove_track(comment)
      message = comment.message
      Pusher.trigger("message_#{message.id}", 'remove_on_deck', {
        id: comment.id,
        count: (message.queue_count - 1).to_s
      })
    end

    def reload_all_rooms
      Pusher.trigger('reloadAllSessions', 'reload_all', {
        message: 'reload_all'
      })
    end

  end
end
