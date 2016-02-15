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
    track = client.get('/resolve', :url => self.content)
    self.responses = track.to_json
  end
end
