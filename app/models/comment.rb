class Comment < ActiveRecord::Base
  include ApplicationHelper

  belongs_to :message
  belongs_to :user

  before_create :resolve

  def album_art_url
    self.responses['artwork_url'].to_s.gsub('large','t500x500')
  end

  def blurred_album_art_url
    album_art_url.gsub('https://i1.sndcdn.com', 'https://tumtable.imgix.net') + '?blur=200'
  end

  def palette_url
    album_art_url.gsub('https://i1.sndcdn.com', 'https://tumtable.imgix.net') + '?colorquant=2&palette=css&colors=2&class=album&zoom=100'
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
