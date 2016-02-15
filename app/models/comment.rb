class Comment < ActiveRecord::Base
  include ApplicationHelper
  include Imgix::Rails::UrlHelper

  belongs_to :message
  belongs_to :user

  before_create :resolve

  def album_art_url
    if self.responses['artwork_url']
      self.responses['artwork_url'].to_s.gsub('large','t500x500')
    elsif self.responses['user']['avatar_url']
      self.responses['user']['avatar_url'].to_s.gsub('large','t500x500')
    else
      'https://i1.sndcdn.com/avatars-000106486517-x71ahg-large.jpg'
    end
  end

  def blurred_album_art_url
    ix_image_url(album_art_url, { blur: 200 })
  end

  def palette_url
    ix_image_url(album_art_url, { palette: 'css', colors: 4, class: 'album', zoom: 100 })
  end

  def reset!
    update_attributes(aired_at: nil, now_playing: false)
  end

  private

  def resolve
    client = SoundCloud.new({
      :client_id     => 'b59d1f4b68bbc8f2b0064188f210117d',
      :client_secret => 'bed0d37bd0eed984cb6d30bf4ee3a2e0'
    })
    response = client.get('/resolve', :url => self.content)
    if response['kind'] == 'playlist'
      first = response['tracks'].first
      self.content = first['permalink_url']
      self.responses = first.to_json

      current_user = self.user
      message = self.message
      tracks = response['tracks']
      tracks.delete(first)
      tracks.each do |comment|
        @comment = message.comments.create! content: comment['permalink_url'], user: current_user
        html = ApplicationController.render(
          assigns: { comment: @comment },
          template: 'comments/_comment',
          layout: false
        )
        Pusher.trigger('message_' + @comment.message.id.to_s, 'on_deck', {
          message: html,
          count: message.queue_count
        })
      end
    else
      self.responses = response.to_json
    end
  end
end
